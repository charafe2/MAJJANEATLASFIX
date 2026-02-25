<?php

namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\ServiceRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ReportController extends Controller
{
    /**
     * Client submits a report about a service request (and the artisan involved).
     *
     * POST /client/service-requests/{serviceRequest}/report
     */
    public function store(Request $request, ServiceRequest $serviceRequest): JsonResponse
    {
        $user   = $request->user();
        $client = $user->client;

        if (!$client || $serviceRequest->client_id !== $client->id) {
            return response()->json(['error' => 'Not found.'], 404);
        }

        $data = $request->validate([
            'message'   => 'required|string|max:2000',
            'photos'    => 'nullable|array|max:5',
            'photos.*'  => 'file|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        // Determine who is being reported (the assigned artisan)
        $artisanUserId = $serviceRequest->acceptedOffer?->artisan?->user_id
            ?? $serviceRequest->artisan?->user_id;

        if (!$artisanUserId) {
            return response()->json(['error' => 'Aucun artisan associé à cette demande.'], 422);
        }

        // Store any uploaded photos
        $photoPaths = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = Storage::url($photo->store('reports', 'public'));
            }
        }

        Report::create([
            'reporter_id'        => $user->id,
            'reported_id'        => $artisanUserId,
            'service_request_id' => $serviceRequest->id,
            'reason'             => 'other',
            'description'        => $data['message'],
            'photos'             => $photoPaths ?: null,
            'status'             => 'pending',
        ]);

        return response()->json(['message' => 'Votre signalement a été envoyé. Nous allons examiner votre demande.']);
    }
}
