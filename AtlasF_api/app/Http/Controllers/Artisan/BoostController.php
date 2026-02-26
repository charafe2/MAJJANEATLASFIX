<?php

namespace App\Http\Controllers\Artisan;

use App\Http\Controllers\Controller;
use App\Models\ArtisanBoost;
use App\Models\BoostPackage;
use App\Models\Notification;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BoostController extends Controller
{
    // ── GET /artisan/boost/packages ────────────────────────────────────────
    // Returns all available paid boost packages (sorted cheapest first).

    public function packages(): JsonResponse
    {
        $packages = BoostPackage::orderBy('price')->get();
        return response()->json(['data' => $packages]);
    }

    // ── POST /artisan/boost/activate ──────────────────────────────────────
    // Consume the oldest available free boost credit for the artisan.
    // Accepts optional service_category_id to boost a specific service.

    public function activate(Request $request): JsonResponse
    {
        $artisan = $request->user()->artisan;
        if (!$artisan) {
            return response()->json(['error' => 'Profil artisan introuvable.'], 404);
        }

        $credit = $artisan->boostCredits()
            ->where('is_used', false)
            ->where(fn($q) => $q->whereNull('expires_at')->orWhere('expires_at', '>', now()))
            ->orderBy('created_at')
            ->first();

        if (!$credit) {
            return response()->json(['error' => 'Aucun boost gratuit disponible.'], 404);
        }

        $credit->update(['is_used' => true]);

        $boost = ArtisanBoost::create([
            'artisan_id'          => $artisan->id,
            'service_category_id' => $request->input('service_category_id'),
            'boost_credit_id'     => $credit->id,
            'boost_type'          => 'referral',
            'start_date'          => now(),
            'end_date'            => now()->addHours($credit->boost_duration_hours),
            'is_active'           => true,
        ]);

        return response()->json([
            'message'    => 'Boost activé ! Votre service est mis en avant pendant ' . $credit->boost_duration_hours . 'h.',
            'boost_until' => $boost->end_date,
        ]);
    }

    // ── POST /artisan/boost/buy ────────────────────────────────────────────
    // Purchase a paid boost package for a specific service.
    //
    // Body: boost_package_id, service_category_id (optional),
    //       card_number, holder_name, expiry, cvv

    public function buy(Request $request): JsonResponse
    {
        $user    = $request->user();
        $artisan = $user->artisan;

        if (!$artisan) {
            return response()->json(['error' => 'Profil artisan introuvable.'], 404);
        }

        $data = $request->validate([
            'boost_package_id'    => 'required|exists:boost_packages,id',
            'service_category_id' => 'nullable|exists:service_categories,id',
            'card_number'         => 'required|string|min:13|max:19',
            'holder_name'         => 'required|string|max:100',
            'expiry'              => 'required|string|max:7',
            'cvv'                 => 'required|string|min:3|max:4',
        ]);

        $package = BoostPackage::findOrFail($data['boost_package_id']);

        // Record the payment
        $payment = Payment::create([
            'payer_id'               => $user->id,
            'payee_id'               => $user->id, // platform keeps boost fees
            'payment_type'           => 'boost',
            'service_amount'         => $package->price,
            'commission_amount'      => 0,
            'transaction_fee_amount' => 0,
            'total_amount'           => $package->price,
            'status'                 => 'completed',
            'transaction_id'         => 'BST-' . strtoupper(Str::random(10)),
        ]);

        // Activate the boost
        $boost = ArtisanBoost::create([
            'artisan_id'          => $artisan->id,
            'service_category_id' => $data['service_category_id'] ?? null,
            'boost_package_id'    => $package->id,
            'boost_type'          => 'paid',
            'start_date'          => now(),
            'end_date'            => now()->addHours($package->duration_hours),
            'is_active'           => true,
        ]);

        Notification::create([
            'user_id' => $user->id,
            'type'    => 'boost',
            'title'   => 'Boost activé',
            'message' => 'Votre boost ' . $package->name . ' est maintenant actif. Votre service sera mis en avant jusqu\'au ' . $boost->end_date->format('d/m/Y à H:i') . '.',
        ]);

        return response()->json([
            'message'         => 'Boost acheté avec succès !',
            'boost_until'     => $boost->end_date,
            'transaction_id'  => $payment->transaction_id,
            'package'         => $package->name,
        ], 201);
    }
}
