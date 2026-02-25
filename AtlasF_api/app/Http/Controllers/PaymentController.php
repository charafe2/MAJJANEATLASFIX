<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\ServiceRequest;
use App\Models\ServiceTimeline;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    /**
     * Client pays for a service request.
     *
     * POST /client/service-requests/{serviceRequest}/pay
     */
    public function pay(Request $request, ServiceRequest $serviceRequest): JsonResponse
    {
        $user   = $request->user();
        $client = $user->client;

        if (!$client || $serviceRequest->client_id !== $client->id) {
            return response()->json(['error' => 'Not found.'], 404);
        }

        if ($serviceRequest->payment_id) {
            return response()->json(['error' => 'Cette demande a déjà été payée.'], 422);
        }

        if (!in_array($serviceRequest->status, ['open', 'in_progress'])) {
            return response()->json(['error' => 'Le paiement n\'est pas disponible pour cette demande.'], 422);
        }

        $request->validate([
            'card_number' => 'required|string|min:13|max:19',
            'holder_name' => 'required|string|max:100',
            'expiry'      => 'required|string|max:7',
            'cvv'         => 'required|string|min:3|max:4',
        ]);

        // Determine the payee (artisan user)
        $artisanUserId = $serviceRequest->acceptedOffer?->artisan?->user_id
            ?? $serviceRequest->artisan?->user_id;

        if (!$artisanUserId) {
            return response()->json(['error' => 'Aucun artisan associé à cette demande.'], 422);
        }

        $amount = $serviceRequest->acceptedOffer?->proposed_price ?? 0;

        $payment = Payment::create([
            'payer_id'               => $user->id,
            'payee_id'               => $artisanUserId,
            'payment_type'           => 'service',
            'service_amount'         => $amount,
            'commission_amount'      => 0,
            'transaction_fee_amount' => 0,
            'total_amount'           => $amount,
            'status'                 => 'completed',
            'transaction_id'         => 'TRX-' . strtoupper(Str::random(12)),
        ]);

        $serviceRequest->update(['payment_id' => $payment->id]);

        ServiceTimeline::create([
            'service_request_id'   => $serviceRequest->id,
            'event_type'           => 'payment_made',
            'triggered_by_user_id' => $user->id,
        ]);

        return response()->json([
            'message'        => 'Paiement effectué avec succès.',
            'transaction_id' => $payment->transaction_id,
            'amount'         => $payment->total_amount,
        ]);
    }
}
