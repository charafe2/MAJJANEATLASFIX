<?php

namespace App\Http\Controllers;

use App\Models\Artisan;
use App\Models\Review;
use App\Models\ServiceRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    /**
     * Check whether the authenticated client has completed at least one
     * service request together with the given artisan.
     */
    public function checkWorkedWith(Request $request, Artisan $artisan): JsonResponse
    {
        $client = $request->user()->client;

        if (!$client) {
            return response()->json([
                'worked_together'    => false,
                'service_request_id' => null,
                'already_reviewed'   => false,
            ]);
        }

        // Find the most recent completed request where this artisan was accepted
        $serviceRequest = ServiceRequest::where('client_id', $client->id)
            ->where('status', 'completed')
            ->whereHas('acceptedOffer', fn ($q) => $q->where('artisan_id', $artisan->id))
            ->latest()
            ->first();

        $alreadyReviewed = false;
        if ($serviceRequest) {
            $alreadyReviewed = Review::where('service_request_id', $serviceRequest->id)
                ->where('client_id', $client->id)
                ->where('artisan_id', $artisan->id)
                ->exists();
        }

        return response()->json([
            'worked_together'    => $serviceRequest !== null,
            'service_request_id' => $serviceRequest?->id,
            'already_reviewed'   => $alreadyReviewed,
        ]);
    }

    /**
     * Store a new client review for an artisan.
     * Only allowed when the client has a completed request with this artisan.
     */
    public function store(Request $request, Artisan $artisan): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'client') {
            return response()->json(['error' => 'Seuls les clients peuvent laisser un avis.'], 403);
        }

        $client = $user->client;
        if (!$client) {
            return response()->json(['error' => 'Profil client introuvable.'], 404);
        }

        $data = $request->validate([
            'rating'             => 'required|integer|min:1|max:5',
            'comment'            => 'nullable|string|max:2000',
            'service_request_id' => 'required|exists:service_requests,id',
        ]);

        // Verify the request belongs to this client, is completed, and involved this artisan
        $serviceRequest = ServiceRequest::where('id', $data['service_request_id'])
            ->where('client_id', $client->id)
            ->where('status', 'completed')
            ->whereHas('acceptedOffer', fn ($q) => $q->where('artisan_id', $artisan->id))
            ->first();

        if (!$serviceRequest) {
            return response()->json([
                'error' => 'Vous ne pouvez laisser un avis qu\'après avoir complété une demande avec cet artisan.',
            ], 403);
        }

        // Prevent duplicate reviews for the same service request
        if (Review::where('service_request_id', $serviceRequest->id)
            ->where('client_id', $client->id)
            ->exists()) {
            return response()->json(['error' => 'Vous avez déjà laissé un avis pour cette demande.'], 422);
        }

        Review::create([
            'service_request_id' => $serviceRequest->id,
            'client_id'          => $client->id,
            'artisan_id'         => $artisan->id,
            'rating'             => $data['rating'],
            'comment'            => $data['comment'] ?? null,
            'is_visible'         => true,
        ]);

        // Recalculate and persist the artisan's aggregate rating
        $newTotal = Review::where('artisan_id', $artisan->id)->where('is_visible', true)->count();
        $newAvg   = Review::where('artisan_id', $artisan->id)->where('is_visible', true)->avg('rating') ?? 0;
        $artisan->update([
            'total_reviews'  => $newTotal,
            'rating_average' => round($newAvg, 2),
        ]);

        return response()->json(['message' => 'Avis soumis avec succès.'], 201);
    }
}
