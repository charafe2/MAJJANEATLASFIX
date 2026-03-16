<?php

namespace App\Http\Controllers\Artisan;

use App\Http\Controllers\Controller;
use App\Models\ArtisanSubscription;
use App\Models\Notification;
use App\Models\Payment;
use App\Models\SubscriptionTier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SubscriptionController extends Controller
{
    /**
     * GET /artisan/subscription/tiers
     * List all available subscription tiers.
     */
    public function tiers(): JsonResponse
    {
        $tiers = SubscriptionTier::orderBy('price')->get();

        return response()->json(['data' => $tiers]);
    }

    /**
     * GET /artisan/subscription
     * Get current artisan's subscription status & limits.
     */
    public function status(Request $request): JsonResponse
    {
        $artisan = $request->user()->artisan;

        if (!$artisan) {
            return response()->json(['error' => 'Profil artisan introuvable.'], 404);
        }

        $tier       = $artisan->getEffectiveTier();
        $usedOffers = $artisan->offersThisMonth();
        $remaining  = $artisan->remainingOffers();

        return response()->json([
            'data' => [
                'current_tier' => [
                    'id'                   => $tier->id,
                    'name'                 => $tier->name,
                    'price'                => $tier->price,
                    'max_offers_per_month' => $tier->max_offers_per_month,
                    'max_team_members'     => $tier->max_team_members,
                    'is_unlimited'         => $tier->isUnlimited(),
                ],
                'offers_used_this_month' => $usedOffers,
                'offers_remaining'       => $remaining, // -1 = unlimited
                'subscription_expires_at' => $artisan->subscription_expires_at,
                'is_boosted'             => $artisan->isBoosted(),
                'active_boost_until'     => $artisan->activeBoost?->end_date,
            ],
        ]);
    }

    /**
     * POST /artisan/subscription/subscribe
     * Subscribe to a tier (upgrade/downgrade).
     *
     * Body: tier_id, card_number, holder_name, expiry, cvv
     */
    public function subscribe(Request $request): JsonResponse
    {
        $user    = $request->user();
        $artisan = $user->artisan;

        if (!$artisan) {
            return response()->json(['error' => 'Profil artisan introuvable.'], 404);
        }

        $data = $request->validate([
            'tier_id'     => 'required|exists:subscription_tiers,id',
            'card_number' => 'nullable|string|min:13|max:19',
            'holder_name' => 'nullable|string|max:100',
            'expiry'      => 'nullable|string|max:7',
            'cvv'         => 'nullable|string|min:3|max:4',
        ]);

        $tier = SubscriptionTier::findOrFail($data['tier_id']);

        // For paid tiers, require payment details
        if (!$tier->isFree()) {
            $request->validate([
                'card_number' => 'required|string|min:13|max:19',
                'holder_name' => 'required|string|max:100',
                'expiry'      => 'required|string|max:7',
                'cvv'         => 'required|string|min:3|max:4',
            ]);
        }

        $currentTier = $artisan->getEffectiveTier();

        if ($currentTier->id === $tier->id) {
            return response()->json(['error' => 'Vous êtes déjà abonné à ce plan.'], 422);
        }

        // Expire any current active subscription
        ArtisanSubscription::where('artisan_id', $artisan->id)
            ->where('status', 'active')
            ->update(['status' => 'expired', 'end_date' => now()]);

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
                'status'                 => 'completed',
                'transaction_id'         => 'SUB-' . strtoupper(Str::random(10)),
            ]);
        }

        $subscription = ArtisanSubscription::create([
            'artisan_id'           => $artisan->id,
            'subscription_tier_id' => $tier->id,
            'start_date'           => now(),
            'end_date'             => $tier->isFree() ? null : now()->addMonth(),
            'status'               => 'active',
            'payment_id'           => $payment?->id,
        ]);

        // Update denormalized fields on artisan
        $artisan->update([
            'current_subscription_tier_id' => $tier->id,
            'subscription_expires_at'      => $subscription->end_date,
        ]);

        Notification::create([
            'user_id' => $user->id,
            'type'    => 'subscription',
            'title'   => 'Abonnement activé',
            'message' => "Votre plan {$tier->name} est maintenant actif." . ($subscription->end_date ? " Valable jusqu'au " . $subscription->end_date->format('d/m/Y') . '.' : ''),
        ]);

        return response()->json([
            'message'        => "Abonnement {$tier->name} activé avec succès !",
            'tier'           => $tier->name,
            'expires_at'     => $subscription->end_date,
            'transaction_id' => $payment?->transaction_id,
        ], 201);
    }
}
