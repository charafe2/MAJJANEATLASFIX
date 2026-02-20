<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Client;
use App\Models\Artisan;
use App\Services\SmsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;
use App\Models\ArtisanSubscription;
use App\Models\SubscriptionTier;
use App\Models\Payment;
class AuthController extends Controller
{
    public function __construct(private SmsService $smsService) {}

    // --------------------------------------------------------
    // PRE-REGISTER  ← NEW
    // Called right after user picks verification method.
    // Creates a bare user row (no password, is_active=false)
    // and immediately fires the OTP to their email/phone.
    // Returns only user_id — Flutter carries it to /verify.
    // --------------------------------------------------------
    public function preRegister(Request $request)
    {
        $request->validate([
            'account_type'        => 'required|in:client,artisan',
            'full_name'           => 'required|string|max:255',
            'birth_date'          => 'required|date|before:-18 years',
            'email'               => 'required|email|unique:users,email',
            'phone'               => 'required|string|unique:users,phone',
            'verification_method' => 'required|in:email,phone',
        ]);

        // Minimal user — temp random password, inactive until verified
        $user = User::create([
            'account_type'        => $request->account_type,
            'auth_provider'       => 'email',
            'full_name'           => $request->full_name,
            'birth_date'          => $request->birth_date,
            'email'               => $request->email,
            'phone'               => $request->phone,
            'password'            => Hash::make(Str::random(32)),
            'verification_method' => $request->verification_method,
            'is_active'           => false,
        ]);

        // Send OTP — if it fails, delete the stub user so the user can retry
        try {
            $this->sendVerificationCode($user);
        } catch (\Exception $e) {
            $user->forceDelete();
            Log::error('preRegister: OTP send failed', ['error' => $e->getMessage()]);
            return response()->json([
                'error' => 'Failed to send verification code: ' . $e->getMessage(),
            ], 500);
        }

        return response()->json([
            'message'             => 'Verification code sent',
            'user_id'             => $user->id,
            'verification_method' => $user->verification_method,
        ], 201);
    }

//web registration

// ─────────────────────────────────────────────────────────────────────────────
// REPLACE your existing register() method in AuthController with this one
// ─────────────────────────────────────────────────────────────────────────────

    public function register(Request $request)
    {
        $request->validate([
            'account_type'  => 'required|in:client,artisan',
            'full_name'     => 'required|string|max:255',
            'birth_date'    => 'required|date|before:-18 years',
            'email'         => 'required|email|unique:users,email',
            'phone'         => 'required|string|unique:users,phone',
            'password'      => 'required|string|min:8|confirmed',
            // shared
            'city'          => 'nullable|string|max:255',
            'address'       => 'nullable|string|max:255',
            // artisan-only
            'service'       => 'nullable|string|max:255',
            'service_type'  => 'nullable|string|max:255',
            'bio'           => 'nullable|string',
            'diploma'       => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
            'referral_code' => 'nullable|string|exists:artisans,referral_code',
        ]);

        // Create user — already active (web flow, no OTP needed)
        $user = User::create([
            'account_type'        => $request->account_type,
            'auth_provider'       => 'email',
            'full_name'           => $request->full_name,
            'birth_date'          => $request->birth_date,
            'email'               => $request->email,
            'phone'               => $request->phone,
            'password'            => Hash::make($request->password),
            'verification_method' => 'email',
            'is_active'           => true,
        ]);

        // ── CLIENTS: create profile immediately and return token ──────────
        if ($user->account_type === 'client') {
            $this->createProfile(
                $user,
                null,
                $request->city,
                $request->address,
            );

            $token = $user->createToken('auth_token')->plainTextToken;
            $user->load('client');

            return response()->json([
                'message'      => 'Account created successfully.',
                'token'        => $token,
                'user'         => $user,
                'account_type' => $user->account_type,
                'user_id'      => $user->id,
            ], 201);
        }

        // ── ARTISANS: stash profile fields in cache, defer to /complete-plan
        // Handle file uploads now so we have the paths ready when plan is picked
        $diplomaPath = null;
        if ($request->hasFile('diploma')) {
            $diplomaPath = $request->file('diploma')->store('diplomas', 'public');
        }

        $photoPaths = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = $photo->store('portfolio', 'public');
            }
        }

        // Stash for 1 hour — consumed by completePlan
        Cache::put("pending_artisan_profile_{$user->id}", [
            'referral_code' => $request->referral_code,
            'city'          => $request->city,
            'address'       => $request->address,
            'service'       => $request->service,
            'service_type'  => $request->service_type,
            'bio'           => $request->bio,
            'diploma_path'  => $diplomaPath,
            'photo_paths'   => $photoPaths,
        ], now()->addHour());

        // Return user_id — Vue carries it to the pricing page
        return response()->json([
            'message'       => 'Account created. Please select your subscription plan.',
            'user_id'       => $user->id,
            'account_type'  => $user->account_type,
            'requires_plan' => true,
        ], 201);
    }
    // --------------------------------------------------------
    // COMPLETE REGISTER  ← NEW
    // Called AFTER /verify confirms the OTP.
    // Receives the real password + all profile fields,
    // sets them on the already-verified user, creates the
    // client/artisan profile row, returns a full auth token.
    // --------------------------------------------------------
    public function completeRegister(Request $request)
    {
        $request->validate([
            'user_id'              => 'required|exists:users,id',
            'password'             => 'required|string|min:8|confirmed',
            // shared
            'city'                 => 'nullable|string|max:255',
            'address'              => 'nullable|string|max:255',
            // artisan-only
            'service'              => 'nullable|string|max:255',
            'service_type'         => 'nullable|string|max:255',
            'bio'                  => 'nullable|string',
            'diploma'              => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
            'referral_code'        => 'nullable|string|exists:artisans,referral_code',
        ]);

        $user = User::findOrFail($request->user_id);

        // Must be verified first
        if (!$user->is_active) {
            return response()->json([
                'error' => 'Account not yet verified. Please verify your code first.',
            ], 403);
        }

        // Idempotent — if profile already exists just return a token
        $alreadyDone = $user->account_type === 'client'
            ? $user->client()->exists()
            : $user->artisan()->exists();

        if ($alreadyDone) {
            $token = $user->tokens()->exists()
                ? $user->createToken('auth_token')->plainTextToken
                : $user->tokens()->first()->plainTextToken;
            $user->load($user->account_type === 'client' ? 'client' : 'artisan');
            return response()->json([
                'message'      => 'Profile already completed',
                'token'        => $user->createToken('auth_token')->plainTextToken,
                'user'         => $user,
                'account_type' => $user->account_type,
                'user_id'      => $user->id,
            ], 200);
        }

        // Set the real password
        $user->update(['password' => Hash::make($request->password)]);

        // Handle file uploads (artisan only)
        $diplomaPath = null;
        if ($request->hasFile('diploma')) {
            $diplomaPath = $request->file('diploma')->store('diplomas', 'public');
        }

        $photoPaths = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = $photo->store('portfolio', 'public');
            }
        }

        $this->createProfile(
            $user,
            $request->referral_code,
            $request->city,
            $request->address,
            $request->service,
            $request->service_type,
            $request->bio,
            $diplomaPath,
            $photoPaths,
        );

        $token = $user->createToken('auth_token')->plainTextToken;
        $user->load($user->account_type === 'client' ? 'client' : 'artisan');

        return response()->json([
            'message'      => 'Account completed successfully',
            'token'        => $token,
            'user'         => $user,
            'account_type' => $user->account_type,
            'user_id'      => $user->id,
        ], 201);
    }

    // --------------------------------------------------------
    // VERIFY CODE  (unchanged logic, small resend-guard tweak)
    // Now also works for pre-registered (is_active=false) users.
    // --------------------------------------------------------
    public function verify(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'code'    => 'required|string|size:4',
        ]);

        $user = User::findOrFail($request->user_id);

        if ($user->is_active) {
            return response()->json(['message' => 'Account already verified', 'user_id' => $user->id], 200);
        }

        $cachedCode = Cache::get("verification_code_{$user->id}");
        if (!$cachedCode) {
            return response()->json(['error' => 'Code expired, please request a new one'], 422);
        }
        if ($cachedCode !== $request->code) {
            return response()->json(['error' => 'Invalid code'], 422);
        }

        // ── Activate the account (DB::table bypasses fillable/casting) ─
        \DB::table('users')
            ->where('id', $user->id)
            ->update(['is_active' => true]);

        // ── Stamp verified_at — wrapped separately so a missing column  ─
        // ── never blocks the activation above                           ─
        try {
            $tsField = $user->verification_method === 'email'
                ? 'email_verified_at'
                : 'phone_verified_at';
            \DB::table('users')
                ->where('id', $user->id)
                ->update([$tsField => now()]);
        } catch (\Exception $e) {
            Log::warning('verified_at stamp failed', [
                'user_id' => $user->id,
                'error'   => $e->getMessage(),
            ]);
        }

        Cache::forget("verification_code_{$user->id}");

        // Reload fresh to confirm is_active = true
        $user->refresh();

        Log::info('User verified', [
            'user_id'   => $user->id,
            'is_active' => $user->is_active,
        ]);

        return response()->json([
            'message'      => 'Account verified successfully',
            'user_id'      => $user->id,
            'account_type' => $user->account_type,
            'is_active'    => $user->is_active,
        ], 200);
    }

    // --------------------------------------------------------
    // RESEND CODE
    // Removed the is_active guard so pre-registered users can resend
    // --------------------------------------------------------
    public function resendCode(Request $request)
    {
        $request->validate(['user_id' => 'required|exists:users,id']);
        $user = User::findOrFail($request->user_id);

        if (Cache::has("resend_cooldown_{$user->id}")) {
            return response()->json([
                'error' => 'Please wait 1 minute before requesting a new code',
            ], 429);
        }

        try {
            $this->sendVerificationCode($user);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }

        return response()->json(['message' => 'New code sent'], 200);
    }

    // --------------------------------------------------------
    // LOGIN
    // --------------------------------------------------------
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }

        if (!$user->is_active) {
            try { $this->sendVerificationCode($user); } catch (\Exception $e) {}
            return response()->json(['error' => 'Account not verified', 'user_id' => $user->id], 403);
        }

        if ($user->is_banned) {
            return response()->json(['error' => 'Account banned: ' . $user->ban_reason], 403);
        }
        if ($user->suspended_until && now()->lt($user->suspended_until)) {
            return response()->json(['error' => 'Account suspended', 'suspended_until' => $user->suspended_until], 403);
        }

        if ($user->account_type === 'client' && !$user->client) {
            $this->createProfile($user);
        } elseif ($user->account_type === 'artisan' && !$user->artisan) {
            $this->createProfile($user);
        }

        $user->update(['last_login' => now()]);
        $token = $user->createToken('auth_token')->plainTextToken;
        $user->load($user->account_type === 'client' ? 'client' : 'artisan');

        return response()->json([
            'token'        => $token,
            'user'         => $user,
            'account_type' => $user->account_type,
            'user_id'=>$user->id,
        ], 200);
    }

    public function googleRedirect()
    {
        return Socialite::driver('google')->stateless()->redirect();
    }

    public function googleCallback(Request $request)
    {
        $frontend = env('FRONTEND_URL', 'http://localhost:5173');

        try {
            $googleUser = Socialite::driver('google')->stateless()->user();
        } catch (\Exception $e) {
            Log::error('Google OAuth callback failed', ['error' => $e->getMessage()]);
            return redirect("{$frontend}/login?error=google_failed");
        }

        // ── Existing user — issue token and send them in ─────
        $existing = User::where('google_id', $googleUser->getId())
            ->orWhere('email', $googleUser->getEmail())
            ->first();

        if ($existing) {
            $existing->update([
                'google_id'  => $googleUser->getId(),
                'avatar_url' => $googleUser->getAvatar() ?? $existing->avatar_url,
            ]);

            // Create missing profile rows (safety net)
            if ($existing->account_type === 'client'  && !$existing->client)  $this->createProfile($existing);
            if ($existing->account_type === 'artisan' && !$existing->artisan) $this->createProfile($existing);

            $token = $existing->createToken('auth_token')->plainTextToken;
            $existing->load($existing->account_type === 'client' ? 'client' : 'artisan');

            $payload = urlencode(base64_encode(json_encode([
                'token'        => $token,
                'user'         => $existing,
                'account_type' => $existing->account_type,
            ])));

            return redirect("{$frontend}/auth/google/success?payload={$payload}");
        }

        // ── New user — stash Google data, let Vue complete the profile ──
        $tempKey = 'google_temp_' . Str::random(32);
        Cache::put($tempKey, [
            'google_id'  => $googleUser->getId(),
            'full_name'  => $googleUser->getName(),
            'email'      => $googleUser->getEmail(),
            'avatar_url' => $googleUser->getAvatar(),
        ], now()->addMinutes(15));

        $params = http_build_query([
            'requires_completion' => 'true',
            'temp_key'            => $tempKey,
            'full_name'           => $googleUser->getName(),
            'email'               => $googleUser->getEmail(),
        ]);

        return redirect("{$frontend}/auth/google/success?{$params}");
    }

    // --------------------------------------------------------
    // GOOGLE OAUTH - Complete profile
    // --------------------------------------------------------
    public function googleComplete(Request $request)
    {
        $request->validate([
            'temp_key'     => 'required|string',
            'account_type' => 'required|in:client,artisan',
            'phone'        => 'required|string|unique:users,phone',
            'birth_date'   => 'required|date|before:-18 years',
        ]);

        $tempData = Cache::get($request->temp_key);
        if (!$tempData) {
            return response()->json(['error' => 'Session expired, please login with Google again'], 422);
        }

        $user = User::create([
            'account_type'        => $request->account_type,
            'auth_provider'       => 'google',
            'google_id'           => $tempData['google_id'],
            'full_name'           => $tempData['full_name'],
            'birth_date'          => $request->birth_date,
            'email'               => $tempData['email'],
            'phone'               => $request->phone,
            'avatar_url'          => $tempData['avatar_url'],
            'password'            => null,
            'is_active'           => true,
            'verification_method' => 'phone',
        ]);

        $this->createProfile($user);
        Cache::forget($request->temp_key);

        $token = $user->createToken('auth_token')->plainTextToken;
        $user->load($user->account_type === 'client' ? 'client' : 'artisan');

        return response()->json([
            'message'      => 'Account created successfully',
            'token'        => $token,
            'user'         => $user,
            'account_type' => $user->account_type,
            'user_id'      => $user->id,
        ], 201);
    }
    // FORGOT PASSWORD
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'method' => 'required|in:email,phone',
            'value'  => 'required|string',
        ]);

        $user = $request->method === 'email'
            ? User::where('email', $request->value)->first()
            : User::where('phone', $request->value)->first();

        if (!$user) {
            return response()->json(['message' => 'Reset code sent if account exists'], 200);
        }

        $code = str_pad(random_int(0, 9999), 4, '0', STR_PAD_LEFT);
        Cache::put("reset_code_{$user->id}", $code, now()->addMinutes(10));

        try {
            if ($request->method === 'email') {
                Mail::raw("Your password reset code: {$code}", function ($msg) use ($user) {
                    $msg->to($user->email)->subject('Reset your password');
                });
            } else {
                $sent = $this->smsService->sendResetCode($user->phone, $code);
                if (!$sent) {
                    Cache::forget("reset_code_{$user->id}");
                    return response()->json(['error' => 'Failed to send SMS'], 500);
                }
            }
        } catch (\Exception $e) {
            Cache::forget("reset_code_{$user->id}");
            return response()->json(['error' => $e->getMessage()], 500);
        }

        return response()->json(['message' => 'Reset code sent', 'user_id' => $user->id], 200);
    }

    // RESET PASSWORD
    public function resetPassword(Request $request)
    {
        $request->validate([
            'user_id'  => 'required|exists:users,id',
            'code'     => 'required|string|size:4',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $cachedCode = Cache::get("reset_code_{$request->user_id}");
        if (!$cachedCode) return response()->json(['error' => 'Code expired'], 422);
        if ($cachedCode !== $request->code) return response()->json(['error' => 'Invalid code'], 422);

        $user = User::findOrFail($request->user_id);
        $user->update(['password' => Hash::make($request->password)]);
        Cache::forget("reset_code_{$request->user_id}");
        $user->tokens()->delete();

        return response()->json(['message' => 'Password reset successfully'], 200);
    }

    // LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully'], 200);
    }

    // ME
    public function me(Request $request)
    {
        $user = $request->user();

        if ($user->account_type === 'client') {
            $user->load('client');
            $client = $user->client;

            return response()->json([
                'id'                => $user->id,
                'name'              => $user->full_name,
                'email'             => $user->email,
                'phone'             => $user->phone,
                'memberSince'       => $user->created_at
                    ? $user->created_at->locale('fr')->translatedFormat('F Y')
                    : null,
                'avatar'            => $user->avatar_url,
                'city'              => $client?->city,
                'activeRequests'    => 0,
                'completedRequests' => (int) ($client?->total_requests ?? 0),
                'avgRating'         => 0,
                'totalSpent'        => $client && $client->total_spent
                    ? number_format((float) $client->total_spent, 0, '.', ' ') . ' DH'
                    : '0 DH',
                'reliabilityScore'  => (int) ($client?->reliability_score ?? 100),
                'requests'          => [],
            ]);
        }

        $user->load(['artisan', 'artisan.activeSubscription.tier']);
        $artisan = $user->artisan;

        $serviceCategory = null;
        if ($artisan?->service_category_id) {
            $serviceCategory = \App\Models\ServiceCategory::find($artisan->service_category_id);
        }

        return response()->json([
            'id'                   => $user->id,
            'name'                 => $user->full_name,
            'email'                => $user->email,
            'phone'                => $user->phone,
            'memberSince'          => $user->created_at
                ? $user->created_at->locale('fr')->translatedFormat('F Y')
                : null,
            'avatar'               => $user->avatar_url,
            'city'                 => $artisan?->city,
            'account_type'         => $user->account_type,
            'business_name'        => $artisan?->business_name,
            'bio'                  => $artisan?->bio,
            'experience_years'     => $artisan?->experience_years,
            'rating_average'       => round((float) ($artisan?->rating_average ?? 0), 1),
            'total_reviews'        => (int) ($artisan?->total_reviews ?? 0),
            'total_jobs_completed' => (int) ($artisan?->total_jobs_completed ?? 0),
            'response_time_avg'    => $artisan?->response_time_avg,
            'confidence_score'     => $artisan?->confidence_score,
            'is_available'         => (bool) ($artisan?->is_available ?? false),
            'is_verified'          => (bool) ($artisan?->is_verified ?? false),
            'referral_code'        => $artisan?->referral_code,
            'service_category'     => $serviceCategory?->name,
            'subscription_tier'    => $artisan?->activeSubscription?->tier?->name ?? null,
            'certifications'       => [],
            'portfolio'            => [],
            'requests'             => [],
        ]);
    }
    // PRIVATE: send verification code via email or SMS
    private function sendVerificationCode(User $user): void
    {
        $code = str_pad(random_int(0, 9999), 4, '0', STR_PAD_LEFT);
        Cache::put("verification_code_{$user->id}", $code, now()->addMinutes(10));
        Cache::put("resend_cooldown_{$user->id}",   true,  now()->addMinute());

        if ($user->verification_method === 'email') {
            Mail::raw(
                "Hello {$user->full_name},\n\nYour AtlasFix verification code is: {$code}\n\nThis code expires in 10 minutes.\n\nAtlasFix Team",
                fn ($msg) => $msg->to($user->email)->subject('Verify your AtlasFix account')
            );
        } else {
            $sent = $this->smsService->sendVerificationCode($user->phone, $code);
            if (!$sent) {
                Cache::forget("verification_code_{$user->id}");
                Cache::forget("resend_cooldown_{$user->id}");
                throw new \Exception('Failed to send SMS. Please try again.');
            }
        }
    }

    // PRIVATE: create client or artisan profile row
    // PRIVATE: create client or artisan profile row
    private function createProfile(
        User    $user,
        ?string $referralCode = null,
        ?string $city         = null,
        ?string $address      = null,
        ?string $service      = null,
        ?string $serviceType  = null,
        ?string $bio          = null,
        ?string $diplomaPath  = null,
        array   $photoPaths   = [],
    ): void {
        if ($user->account_type === 'client') {
            Client::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'city'              => $city,
                    'address'           => $address,
                    'total_requests'    => 0,
                    'total_spent'       => 0,
                    'reliability_score' => 100,
                    'profile_completed' => false,
                ]
            );
        } else {
            $referredById = null;
            if ($referralCode) {
                $referrer     = Artisan::where('referral_code', $referralCode)->first();
                $referredById = $referrer?->id;
            }

            $serviceCategoryId = $this->resolveServiceCategoryId($service);

            Artisan::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'referral_code'       => $this->generateReferralCode($user),
                    'referred_by_id'      => $referredById,
                    'service_category_id' => $serviceCategoryId,
                    'city'                => $city,
                    'address'             => $address,
                    'bio'                 => $bio,
                    'is_available'        => true,
                    'is_verified'         => false,
                    'profile_completed'   => false,
                ]
            );
        }
    }

    private function resolveServiceCategoryId(?string $serviceSlug): ?int
    {
        if (!$serviceSlug) return null;

        $slugMap = [
            'plomberie'     => 'Plomberie',
            'electricite'   => 'Électricité',
            'menuiserie'    => 'Menuiserie',
            'peinture'      => 'Peinture',
            'maconnerie'    => 'Maçonnerie',
            'climatisation' => 'Chauffage, Ventilation et Climatisation',
            'carrelage'     => 'Carrelage',
            'jardinage'     => 'Jardinage',
        ];

        $categoryName = $slugMap[$serviceSlug] ?? null;
        if (!$categoryName) return null;

        return \App\Models\ServiceCategory::where('name', $categoryName)->value('id');
    }

    // PRIVATE: generate unique referral code
    private function generateReferralCode(User $user): string
    {
        $base = strtoupper(substr(str_replace(' ', '', $user->full_name), 0, 5));
        do {
            $code = $base . '-' . strtoupper(Str::random(4));
        } while (Artisan::where('referral_code', $code)->exists());

        return $code;
    }

// ─────────────────────────────────────────────────────────────────────────────
// 1. ADD THIS ROUTE to your routes file (alongside the other auth routes)
// ─────────────────────────────────────────────────────────────────────────────
//
// Route::post('complete-plan', [AuthController::class, 'completePlan']);
//
// ─────────────────────────────────────────────────────────────────────────────
// 2. ADD THESE IMPORTS to the top of AuthController.php (if not already there)
// ─────────────────────────────────────────────────────────────────────────────
//
// use App\Models\ArtisanSubscription;
// use App\Models\SubscriptionTier;
// use App\Models\Payment;
//
// ─────────────────────────────────────────────────────────────────────────────
// 3. ADD THIS METHOD inside AuthController
// ─────────────────────────────────────────────────────────────────────────────

    // --------------------------------------------------------
    // COMPLETE PLAN  (web artisan flow)
    // Called when the artisan picks a subscription tier on
    // the pricing page. At this point the user row already
    // exists and is_active = true (created by /register).
    //
    // Flow:
    //   POST /register  →  returns { user_id, requires_plan: true }
    //   [pricing page]
    //   POST /complete-plan  →  creates artisan profile + subscription row
    //                        →  returns auth token
    // --------------------------------------------------------
   public function completePlan(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'plan'    => 'required|in:basic,pro,premium,business',
        ]);

        $user = User::findOrFail($request->user_id);

        if (!$user->is_active) {
            return response()->json(['error' => 'Account not yet verified.'], 403);
        }

        if ($user->account_type !== 'artisan') {
            return response()->json(['error' => 'Plan selection is only available for artisan accounts.'], 422);
        }

        // ── Resolve tier first so we fail fast if plan name is wrong ─────
        $tier = SubscriptionTier::where('name', $request->plan)->firstOrFail();

        // ── Create artisan profile row if not already there ───────────────
        $pending = Cache::get("pending_artisan_profile_{$user->id}", []);

        if (!$user->artisan()->exists()) {
            $this->createProfile(
                $user,
                $pending['referral_code'] ?? null,
                $pending['city']          ?? null,
                $pending['address']       ?? null,
                $pending['service']       ?? null,
                null,
                $pending['bio']           ?? null,
                null,
                [],
            );
        }

        // ── CRITICAL: refresh so $user->artisan is no longer null ─────────
        $user->refresh();
        $artisan = $user->artisan;

        // ── Always apply pending profile data ────────────────────────────
        // This handles the case where the artisan row was created without
        // profile data (e.g., via the login safety net before completePlan ran).
        if (!empty($pending)) {
            $profileUpdate = [];
            if (!empty($pending['city']))    $profileUpdate['city']    = $pending['city'];
            if (!empty($pending['address'])) $profileUpdate['address'] = $pending['address'];
            if (!empty($pending['bio']))     $profileUpdate['bio']     = $pending['bio'];
            if (!empty($pending['service'])) {
                $categoryId = $this->resolveServiceCategoryId($pending['service']);
                if ($categoryId) $profileUpdate['service_category_id'] = $categoryId;
            }
            if (!empty($profileUpdate)) {
                $artisan->update($profileUpdate);
            }
            Cache::forget("pending_artisan_profile_{$user->id}");
        }

        if (!$artisan) {
            Log::error('completePlan: artisan row missing after createProfile', ['user_id' => $user->id]);
            return response()->json(['error' => 'Failed to create artisan profile. Please try again.'], 500);
        }

        // ── Idempotency — already has active subscription ─────────────────
        if ($artisan->subscriptions()->where('status', 'active')->exists()) {
            $activeSub = $artisan->subscriptions()
                                 ->where('status', 'active')
                                 ->with('tier')
                                 ->latest()
                                 ->first();

            $user->load('artisan');

            return response()->json([
                'message'      => 'Profile already completed.',
                'token'        => $user->createToken('auth_token')->plainTextToken,
                'user'         => $user,
                'account_type' => $user->account_type,
                'user_id'      => $user->id,
                'plan'         => $activeSub->tier->name,
            ], 200);
        }

        // ── Create Payment row (only for paid tiers) ──────────────────────
        $payment = null;

        if (!$tier->isFree()) {
            $payment = Payment::create([
                'payer_id'               => $user->id,
                'payee_id'               => $user->id,
                'payment_type'           => 'subscription',
                'service_amount'         => $tier->price,
                'commission_amount'      => 0,
                'transaction_fee_amount' => 0,
                'total_amount'           => $tier->price,
                'status'                 => 'pending',
                'transaction_id'         => null,
            ]);
        }

        // ── Create ArtisanSubscription row ────────────────────────────────
        $artisan->subscriptions()->create([
            'subscription_tier_id' => $tier->id,
            'start_date'           => now()->toDateString(),
            'end_date'             => $tier->isFree() ? null : now()->addMonth()->toDateString(),
            'status'               => $tier->isFree() ? 'active' : 'pending',
            'payment_id'           => $payment?->id,
        ]);

        // ── Stamp the current tier on the artisan row ─────────────────────
        $artisan->update(['current_subscription_tier_id' => $tier->id]);

        // ── Return token ──────────────────────────────────────────────────
        $token = $user->createToken('auth_token')->plainTextToken;
        $user->load('artisan');

        return response()->json([
            'message'      => 'Account completed successfully.',
            'token'        => $token,
            'user'         => $user,
            'account_type' => $user->account_type,
            'user_id'      => $user->id,
            'plan'         => $tier->name,
            'payment'      => $payment ? [
                'id'     => $payment->id,
                'amount' => $payment->total_amount,
                'status' => $payment->status,
            ] : null,
        ], 201);
    }

}