<?php

namespace App\Http\Controllers;

use App\Models\Appointment;
use App\Models\ArtisanOffer;
use App\Models\ServiceRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AgendaController extends Controller
{
    // ── Duration map for form select values ───────────────────────────────
    private const DURATION_MAP = [
        '30min' => 30,
        '1h'    => 60,
        '2h'    => 120,
        '3h'    => 180,
    ];

    // ── LIST: all appointments for the current user ───────────────────────

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type === 'artisan') {
            $artisan = $user->artisan;
            if (!$artisan) {
                return response()->json(['error' => 'Artisan profile not found.'], 404);
            }

            // Manual appointments created by this artisan
            $manual = Appointment::with(['client.user'])
                ->where('artisan_id', $artisan->id)
                ->where('status', '!=', 'cancelled')
                ->get()
                ->map(fn ($a) => $this->formatManual($a, 'artisan'));

            // Accepted service requests (artisan was chosen)
            $fromOffers = ArtisanOffer::with([
                    'serviceRequest.client.user',
                    'serviceRequest.serviceType',
                ])
                ->where('artisan_id', $artisan->id)
                ->where('status', 'accepted')
                ->get()
                ->map(fn ($o) => $this->formatFromOffer($o));

            $all = $manual->concat($fromOffers)->sortBy('scheduled_at')->values();

        } else {
            $client = $user->client;
            if (!$client) {
                return response()->json(['error' => 'Client profile not found.'], 404);
            }

            // Manual appointments linked to this client
            $manual = Appointment::with(['artisan.user'])
                ->where('client_id', $client->id)
                ->where('status', '!=', 'cancelled')
                ->get()
                ->map(fn ($a) => $this->formatManual($a, 'client'));

            // Service requests the client accepted an offer for
            $fromRequests = ServiceRequest::with([
                    'acceptedOffer.artisan.user',
                    'serviceType',
                ])
                ->where('client_id', $client->id)
                ->whereIn('status', ['in_progress', 'completed'])
                ->whereNotNull('accepted_offer_id')
                ->get()
                ->map(fn ($sr) => $this->formatFromRequest($sr));

            $all = $manual->concat($fromRequests)->sortBy('scheduled_at')->values();
        }

        return response()->json(['data' => $all]);
    }

    // ── CREATE: manual appointment ────────────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'title'            => 'required|string|max:255',
            'client_name'      => 'nullable|string|max:255',
            'client_phone'     => 'nullable|string|max:30',
            'date'             => 'required|date_format:Y-m-d',
            'time'             => 'required|date_format:H:i',
            'duration'         => 'nullable|in:30min,1h,2h,3h',
            'rdv_type'         => 'nullable|in:sur_place,visioconference',
            'city'             => 'nullable|string|max:100',
            'notes'            => 'nullable|string|max:2000',
        ]);

        $scheduledAt     = $data['date'] . ' ' . $data['time'] . ':00';
        $durationMinutes = self::DURATION_MAP[$data['duration'] ?? ''] ?? null;

        if ($user->account_type === 'artisan') {
            $artisanId = $user->artisan?->id;
            $clientId  = null;
        } else {
            $artisanId = null;
            $clientId  = $user->client?->id;
        }

        $appointment = Appointment::create([
            'artisan_id'       => $artisanId,
            'client_id'        => $clientId,
            'title'            => $data['title'],
            'client_name'      => $data['client_name'] ?? null,
            'client_phone'     => $data['client_phone'] ?? null,
            'scheduled_at'     => $scheduledAt,
            'duration_minutes' => $durationMinutes,
            'status'           => 'scheduled',
            'rdv_type'         => $data['rdv_type'] ?? 'sur_place',
            'city'             => $data['city'] ?? null,
            'notes'            => $data['notes'] ?? null,
        ]);

        $appointment->load(['artisan.user', 'client.user']);

        $role   = $user->account_type;
        $result = $this->formatManual($appointment, $role);

        return response()->json(['data' => $result], 201);
    }

    // ── Formatters ────────────────────────────────────────────────────────

    private function formatManual(Appointment $a, string $role): array
    {
        if ($role === 'artisan') {
            $contactName  = $a->client_name ?? $a->client?->user?->full_name;
            $contactPhone = $a->client_phone ?? $a->client?->user?->phone;
        } else {
            $contactName  = $a->artisan?->user?->full_name;
            $contactPhone = $a->artisan?->user?->phone;
        }

        return [
            'id'               => $a->id,
            'type'             => 'manual',
            'title'            => $a->title,
            'scheduled_at'     => $a->scheduled_at->toIso8601String(),
            'duration_minutes' => $a->duration_minutes,
            'city'             => $a->city,
            'status'           => $a->status,          // scheduled / completed / cancelled
            'contact_name'     => $contactName,
            'contact_phone'    => $contactPhone,
            'rdv_type'         => $a->rdv_type,
            'notes'            => $a->notes,
        ];
    }

    private function formatFromOffer(ArtisanOffer $offer): array
    {
        $sr = $offer->serviceRequest;

        return [
            'id'               => 'sr-' . $sr->id,
            'type'             => 'service_request',
            'title'            => $sr->title ?? $sr->serviceType?->name ?? 'Service',
            'scheduled_at'     => $sr->updated_at->toIso8601String(),
            'duration_minutes' => $offer->estimated_duration,
            'city'             => $sr->city,
            'status'           => $sr->status === 'completed' ? 'completed' : 'scheduled',
            'contact_name'     => $sr->client?->user?->full_name,
            'contact_phone'    => $sr->client?->user?->phone,
            'rdv_type'         => $sr->service_mode ?? 'sur_place',
            'notes'            => $sr->notes,
        ];
    }

    private function formatFromRequest(ServiceRequest $sr): array
    {
        $offer = $sr->acceptedOffer;

        return [
            'id'               => 'sr-' . $sr->id,
            'type'             => 'service_request',
            'title'            => $sr->title ?? $sr->serviceType?->name ?? 'Service',
            'scheduled_at'     => $sr->updated_at->toIso8601String(),
            'duration_minutes' => $offer?->estimated_duration,
            'city'             => $sr->city,
            'status'           => $sr->status === 'completed' ? 'completed' : 'scheduled',
            'contact_name'     => $offer?->artisan?->user?->full_name,
            'contact_phone'    => $offer?->artisan?->user?->phone,
            'rdv_type'         => $sr->service_mode ?? 'sur_place',
            'notes'            => $sr->notes,
        ];
    }
}
