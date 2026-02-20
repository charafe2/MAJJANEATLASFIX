<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use App\Models\ArtisanOffer;
use App\Models\ServiceCategory;
use App\Models\ServiceRequest;
use App\Models\ServiceRequestPhoto;
use App\Models\ServiceTimeline;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ServiceRequestController extends Controller
{
    // ── STEP 1: List all active categories ───────────────────────────────────

    public function getCategories(): JsonResponse
    {
        $categories = ServiceCategory::where('is_active', true)
            ->orderBy('display_order')
            ->get(['id', 'name', 'icon']);

        return response()->json(['data' => $categories]);
    }

    // ── STEP 2: Service types for a given category ────────────────────────────

    public function getServiceTypes(ServiceCategory $category): JsonResponse
    {
        $types = $category->serviceTypes()
            ->where('is_active', true)
            ->orderBy('display_order')
            ->get(['id', 'name']);

        return response()->json(['data' => $types]);
    }

    // ── STEP 3: Create the service request ───────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'client') {
            return response()->json(['error' => 'Only clients can submit service requests.'], 403);
        }

        $client = $user->client;
        if (!$client) {
            return response()->json(['error' => 'Client profile not found.'], 404);
        }

        $data = $request->validate([
            'service_category_id' => 'required|exists:service_categories,id',
            'service_type_id'     => 'required|exists:service_types,id',
            'title'               => 'nullable|string|max:255',
            'description'         => 'nullable|string|max:2000',
            'city'                => 'required|string|max:100',
            'service_mode'        => 'nullable|in:sur_place,a_distance',
            'notes'               => 'nullable|string|max:1000',
            'budget_min'          => 'nullable|numeric|min:0',
            'budget_max'          => 'nullable|numeric|min:0|gte:budget_min',
            'request_type'        => 'nullable|in:public,direct',
            'target_artisan_id'   => 'nullable|exists:artisans,id',
            'photos'              => 'nullable|array|max:5',
            'photos.*'            => 'file|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        DB::beginTransaction();

        try {
            $serviceRequest = ServiceRequest::create([
                'client_id'           => $client->id,
                'service_category_id' => $data['service_category_id'],
                'service_type_id'     => $data['service_type_id'],
                'title'               => $data['title'] ?? null,
                'description'         => $data['description'] ?? null,
                'city'                => $data['city'],
                'service_mode'        => $data['service_mode'] ?? 'sur_place',
                'notes'               => $data['notes'] ?? null,
                'budget_min'          => $data['budget_min'] ?? null,
                'budget_max'          => $data['budget_max'] ?? null,
                'status'              => 'open',
                'request_type'        => $data['request_type'] ?? 'public',
                'target_artisan_id'   => $data['target_artisan_id'] ?? null,
            ]);

            // Handle photo uploads
            if ($request->hasFile('photos')) {
                $order = 1;
                foreach ($request->file('photos') as $photo) {
                    $path = $photo->store('service-requests/photos', 'public');
                    ServiceRequestPhoto::create([
                        'service_request_id' => $serviceRequest->id,
                        'photo_url'          => Storage::url($path),
                        'display_order'      => $order++,
                    ]);
                }
            }

            // Log the creation event in the timeline
            ServiceTimeline::create([
                'service_request_id'   => $serviceRequest->id,
                'event_type'           => 'created',
                'triggered_by_user_id' => $user->id,
            ]);

            // Increment client's total_requests counter
            $client->increment('total_requests');

            DB::commit();

            $serviceRequest->load(['category', 'serviceType', 'photos']);

            return response()->json([
                'message' => 'Service request created successfully.',
                'data'    => $serviceRequest,
            ], 201);

        } catch (\Throwable $e) {
            DB::rollBack();
            $message = app()->environment('local')
                ? $e->getMessage()
                : 'Failed to create request. Please try again.';
            return response()->json(['error' => $message], 500);
        }
    }

    // ── LIST client's own requests ────────────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type !== 'client') {
            return response()->json(['error' => 'Only clients can view their requests.'], 403);
        }

        $client = $user->client;
        if (!$client) {
            return response()->json(['data' => []]);
        }

        $status = $request->query('status');

        $query = ServiceRequest::with(['category', 'serviceType', 'photos', 'offers.artisan.user', 'acceptedOffer'])
            ->where('client_id', $client->id)
            ->orderBy('created_at', 'desc');

        if ($status) {
            $query->where('status', $status);
        }

        $requests = $query->paginate(15);

        return response()->json($requests);
    }

    // ── SHOW a single request ─────────────────────────────────────────────────

    public function show(Request $request, ServiceRequest $serviceRequest): JsonResponse
    {
        $user   = $request->user();
        $client = $user->client;

        if (!$client || $serviceRequest->client_id !== $client->id) {
            return response()->json(['error' => 'Not found.'], 404);
        }

        $serviceRequest->load([
            'category',
            'serviceType',
            'photos',
            'offers.artisan.user',
            'acceptedOffer.artisan.user',
            'timeline',
            'payment',
        ]);

        return response()->json(['data' => $serviceRequest]);
    }

    // ── CANCEL a request ──────────────────────────────────────────────────────

    public function cancel(Request $request, ServiceRequest $serviceRequest): JsonResponse
    {
        $user   = $request->user();
        $client = $user->client;

        if (!$client || $serviceRequest->client_id !== $client->id) {
            return response()->json(['error' => 'Not found.'], 404);
        }

        if (!in_array($serviceRequest->status, ['open', 'in_progress'])) {
            return response()->json(['error' => 'This request cannot be cancelled.'], 422);
        }

        $serviceRequest->update(['status' => 'cancelled']);

        ServiceTimeline::create([
            'service_request_id'   => $serviceRequest->id,
            'event_type'           => 'cancelled',
            'triggered_by_user_id' => $user->id,
        ]);

        return response()->json(['message' => 'Request cancelled successfully.']);
    }

    // ── ACCEPT an artisan offer ───────────────────────────────────────────────

    public function acceptOffer(Request $request, ServiceRequest $serviceRequest, ArtisanOffer $offer): JsonResponse
    {
        $client = $request->user()->client;

        if (!$client || $serviceRequest->client_id !== $client->id) {
            return response()->json(['error' => 'Not found.'], 404);
        }
        if ($offer->service_request_id !== $serviceRequest->id) {
            return response()->json(['error' => 'Offer does not belong to this request.'], 422);
        }
        if ($serviceRequest->status !== 'open') {
            return response()->json(['error' => 'Request is no longer open.'], 422);
        }

        DB::beginTransaction();
        try {
            $offer->update(['status' => 'accepted']);

            ArtisanOffer::where('service_request_id', $serviceRequest->id)
                ->where('id', '!=', $offer->id)
                ->where('status', 'pending')
                ->update(['status' => 'rejected']);

            $serviceRequest->update([
                'accepted_offer_id' => $offer->id,
                'status'            => 'in_progress',
            ]);

            ServiceTimeline::create([
                'service_request_id'   => $serviceRequest->id,
                'event_type'           => 'offer_accepted',
                'triggered_by_user_id' => $request->user()->id,
            ]);

            DB::commit();

            $serviceRequest->load(['offers.artisan.user', 'acceptedOffer.artisan.user']);
            return response()->json(['message' => 'Offer accepted.', 'data' => $serviceRequest]);

        } catch (\Throwable) {
            DB::rollBack();
            return response()->json(['error' => 'Failed to accept offer.'], 500);
        }
    }

    // ── REJECT an artisan offer ───────────────────────────────────────────────

    public function rejectOffer(Request $request, ServiceRequest $serviceRequest, ArtisanOffer $offer): JsonResponse
    {
        $client = $request->user()->client;

        if (!$client || $serviceRequest->client_id !== $client->id) {
            return response()->json(['error' => 'Not found.'], 404);
        }
        if ($offer->service_request_id !== $serviceRequest->id) {
            return response()->json(['error' => 'Offer does not belong to this request.'], 422);
        }
        if ($offer->status !== 'pending') {
            return response()->json(['error' => 'This offer cannot be rejected.'], 422);
        }

        $offer->update(['status' => 'rejected']);

        return response()->json(['message' => 'Offer rejected.']);
    }
}
