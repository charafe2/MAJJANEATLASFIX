<?php

namespace App\Http\Controllers\Artisan;

use App\Http\Controllers\Controller;
use App\Models\ArtisanOffer;
use App\Models\Client;
use App\Models\Notification;
use App\Models\ServiceRequest;
use App\Models\ServiceTimeline;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ServiceRequestController extends Controller
{
    // ── LIST open client requests (artisan browse) ────────────────────────

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'artisan') {
            return response()->json(['error' => 'Only artisans can browse requests.'], 403);
        }

        $artisan = $user->artisan;
        if (!$artisan) {
            return response()->json(['error' => 'Artisan profile not found.'], 404);
        }

        // Exclude requests this artisan already offered on
        $alreadyOffered = ArtisanOffer::where('artisan_id', $artisan->id)
            ->pluck('service_request_id');

        $type = $request->query('type', 'public');

        if ($type === 'direct') {
            $query = ServiceRequest::with(['client.user', 'category', 'serviceType', 'photos'])
                ->where('status', 'open')
                ->where('request_type', 'direct')
                ->where('target_artisan_id', $artisan->id)
                ->whereNotIn('id', $alreadyOffered)
                ->orderBy('created_at', 'desc');
        } else {
            $query = ServiceRequest::with(['client.user', 'category', 'serviceType', 'photos'])
                ->where('status', 'open')
                ->where('request_type', 'public')
                ->whereNotIn('id', $alreadyOffered)
                ->orderBy('created_at', 'desc');
        }

        // Search: title / description / city
        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('title', 'ilike', "%{$search}%")
                  ->orWhere('description', 'ilike', "%{$search}%")
                  ->orWhere('city', 'ilike', "%{$search}%");
            });
        }

        // Date filter
        if ($date = $request->query('date')) {
            match ($date) {
                'today' => $query->whereDate('created_at', today()),
                'week'  => $query->where('created_at', '>=', now()->startOfWeek()),
                'month' => $query->where('created_at', '>=', now()->startOfMonth()),
                default => null,
            };
        }

        // Service category filter
        if ($categoryId = $request->query('category_id')) {
            $query->where('service_category_id', $categoryId);
        }

        $requests = $query->paginate(15);

        return response()->json($requests);
    }

    // ── SUBMIT an offer ───────────────────────────────────────────────────

    public function submitOffer(Request $request, ServiceRequest $serviceRequest): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'artisan') {
            return response()->json(['error' => 'Only artisans can submit offers.'], 403);
        }

        $artisan = $user->artisan;
        if (!$artisan) {
            return response()->json(['error' => 'Artisan profile not found.'], 404);
        }

        if ($serviceRequest->status !== 'open') {
            return response()->json(['error' => 'This request is no longer open.'], 422);
        }

        // Prevent duplicate offers
        $existing = ArtisanOffer::where('service_request_id', $serviceRequest->id)
            ->where('artisan_id', $artisan->id)
            ->first();

        if ($existing) {
            return response()->json(['error' => 'You have already submitted an offer for this request.'], 422);
        }

        // Enforce subscription tier offer limits
        if (!$artisan->canSubmitOffer()) {
            $tier = $artisan->getEffectiveTier();
            return response()->json([
                'error' => "Vous avez atteint la limite de {$tier->max_offers_per_month} offres/mois de votre plan {$tier->name}. Passez à un plan supérieur pour envoyer plus d'offres.",
                'limit_reached' => true,
                'current_tier'  => $tier->name,
                'max_offers'    => $tier->max_offers_per_month,
                'offers_used'   => $artisan->offersThisMonth(),
            ], 403);
        }

        $data = $request->validate([
            'proposed_price'     => 'required|numeric|min:0',
            'estimated_duration' => 'required|integer|min:1',
            'description'        => 'nullable|string|max:1000',
        ]);

        DB::beginTransaction();
        try {
            $offer = ArtisanOffer::create([
                'service_request_id' => $serviceRequest->id,
                'artisan_id'         => $artisan->id,
                'proposed_price'     => $data['proposed_price'],
                'estimated_duration' => $data['estimated_duration'],
                'description'        => $data['description'] ?? null,
                'status'             => 'pending',
                'has_active_boost'   => $artisan->activeBoost()->exists(),
            ]);

            ServiceTimeline::create([
                'service_request_id'   => $serviceRequest->id,
                'event_type'           => 'offer_submitted',
                'triggered_by_user_id' => $user->id,
            ]);

            DB::commit();

            // Notify the client that a new offer was received
            $requestTitle = $serviceRequest->title ?? 'sans titre';
            Notification::create([
                'user_id' => $serviceRequest->client->user_id,
                'type'    => 'new_offer',
                'title'   => 'Nouvelle offre reçue',
                'message' => $user->full_name . " a soumis une offre pour votre demande \"{$requestTitle}\".",
            ]);

            return response()->json(['message' => 'Offer submitted successfully.', 'data' => $offer], 201);

        } catch (\Throwable $e) {
            DB::rollBack();
            $message = app()->environment('local') ? $e->getMessage() : 'Failed to submit offer.';
            return response()->json(['error' => $message], 500);
        }
    }

    // ── MY OFFERS (artisan's submitted offers) ────────────────────────────

    public function myOffers(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'artisan') {
            return response()->json(['error' => 'Only artisans can view their offers.'], 403);
        }

        $artisan = $user->artisan;
        if (!$artisan) {
            return response()->json(['error' => 'Artisan profile not found.'], 404);
        }

        $query = ArtisanOffer::with([
                'serviceRequest.client.user',
                'serviceRequest.category',
                'serviceRequest.serviceType',
            ])
            ->where('artisan_id', $artisan->id)
            ->whereIn('status', ['pending', 'accepted'])
            ->orderBy('created_at', 'desc');

        // Tab filter
        $tab = $request->query('tab', 'all');
        match ($tab) {
            'pending'   => $query->where('status', 'pending'),
            'confirmed' => $query->where('status', 'accepted')
                                 ->whereHas('serviceRequest', fn ($q) => $q->where('status', 'in_progress')),
            'completed' => $query->where('status', 'accepted')
                                 ->whereHas('serviceRequest', fn ($q) => $q->where('status', 'completed')),
            default     => null,
        };

        $offers = $query->get();

        return response()->json(['data' => $offers]);
    }

    // ── SHOW a single accepted request (artisan-side detail) ─────────────

    public function show(Request $request, ServiceRequest $serviceRequest): JsonResponse
    {
        $user    = $request->user();
        $artisan = $user->artisan;

        if ($user->account_type !== 'artisan' || !$artisan) {
            return response()->json(['error' => 'Only artisans can access this.'], 403);
        }

        // Verify the artisan has an accepted offer on this request
        $offer = ArtisanOffer::where('service_request_id', $serviceRequest->id)
            ->where('artisan_id', $artisan->id)
            ->where('status', 'accepted')
            ->first();

        if (!$offer) {
            return response()->json(['error' => 'Not found.'], 404);
        }

        $serviceRequest->load([
            'category',
            'serviceType',
            'photos',
            'client.user',
            'timeline',
            'payment',
        ]);

        return response()->json([
            'data'  => $serviceRequest,
            'offer' => $offer,
        ]);
    }

    // ── CLIENT PROFILE (artisan-side view) ───────────────────────────────

    public function clientProfile(Request $request, Client $client): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'artisan') {
            return response()->json(['error' => 'Only artisans can view client profiles.'], 403);
        }

        $client->load('user');

        $activeCount    = $client->serviceRequests()->whereIn('status', ['open', 'in_progress'])->count();
        $completedCount = $client->serviceRequests()->where('status', 'completed')->count();

        $recentRequests = $client->serviceRequests()
            ->with(['category', 'serviceType', 'acceptedOffer.artisan.user'])
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        $clientUser = $client->user;

        return response()->json([
            'user' => [
                'full_name'    => $clientUser->full_name,
                'avatar_url'   => $clientUser->resolved_avatar,
                'city'         => $client->city ?? $clientUser->city ?? '',
                'phone'        => $clientUser->phone,
                'email'        => $clientUser->email,
                'created_at'   => $clientUser->created_at?->toIso8601String(),
                'is_verified'  => (bool) ($clientUser->email_verified_at || $clientUser->phone_verified_at ?? false),
            ],
            'stats' => [
                'active_requests'    => $activeCount,
                'completed_requests' => $completedCount,
                'total_spent'        => (float) ($client->total_spent ?? 0),
                'average_rating'     => 0,
                'trust_score'        => (float) ($client->reliability_score ?? 0),
            ],
            'history' => $recentRequests->map(function ($sr) {
                $offer   = $sr->acceptedOffer;
                $artisan = $offer?->artisan;
                $aUser   = $artisan?->user;

                return [
                    'id'           => $sr->id,
                    'description'  => $sr->description ?? $sr->title ?? 'Demande',
                    'status'       => $sr->status,
                    'created_at'   => $sr->created_at?->toIso8601String(),
                    'rating'       => 0,
                    'category'     => $sr->category ? ['name' => $sr->category->name] : null,
                    'service_type' => $sr->serviceType ? ['name' => $sr->serviceType->name] : null,
                    'artisan'      => $artisan ? [
                        'user' => ['full_name' => $aUser?->full_name ?? 'Artisan'],
                    ] : null,
                ];
            })->values(),
        ]);
    }
}
