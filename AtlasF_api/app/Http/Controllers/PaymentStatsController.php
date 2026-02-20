<?php

namespace App\Http\Controllers;

use App\Models\ArtisanOffer;
use App\Models\ServiceRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentStatsController extends Controller
{
    // ── LIST: payment history + summary stats for the current user ────────

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type === 'artisan') {
            $artisan = $user->artisan;
            if (!$artisan) {
                return response()->json(['error' => 'Artisan profile not found.'], 404);
            }

            // Accepted offers = jobs where this artisan was hired
            $rows = ArtisanOffer::with([
                    'serviceRequest.client.user',
                    'serviceRequest.serviceType',
                ])
                ->where('artisan_id', $artisan->id)
                ->where('status', 'accepted')
                ->get()
                ->sortByDesc(fn ($o) => optional($o->serviceRequest)->updated_at)
                ->values()
                ->map(fn ($o) => $this->formatOffer($o));

        } else {
            $client = $user->client;
            if (!$client) {
                return response()->json(['error' => 'Client profile not found.'], 404);
            }

            // Service requests the client accepted an offer for
            $rows = ServiceRequest::with([
                    'acceptedOffer.artisan.user',
                    'serviceType',
                ])
                ->where('client_id', $client->id)
                ->whereIn('status', ['in_progress', 'completed'])
                ->whereNotNull('accepted_offer_id')
                ->orderByDesc('updated_at')
                ->get()
                ->map(fn ($sr) => $this->formatRequest($sr));
        }

        $completed = $rows->where('status', 'completed');
        $pending   = $rows->where('status', 'pending');

        $stats = [
            'total_revenue'   => round($rows->sum('amount'), 2),
            'completed_total' => round($completed->sum('amount'), 2),
            'completed_count' => $completed->count(),
            'pending_total'   => round($pending->sum('amount'), 2),
            'pending_count'   => $pending->count(),
        ];

        return response()->json([
            'stats'    => $stats,
            'payments' => $rows->values(),
        ]);
    }

    // ── Formatters ────────────────────────────────────────────────────────

    private function formatOffer(ArtisanOffer $offer): array
    {
        $sr     = $offer->serviceRequest;
        $name   = $sr->client?->user?->full_name ?? '—';
        $status = ($sr->status ?? '') === 'completed' ? 'completed' : 'pending';

        return [
            'id'       => 'offer-' . $offer->id,
            'client'   => $name,
            'initials' => strtoupper(mb_substr($name, 0, 1)),
            'service'  => $sr->title ?? $sr->serviceType?->name ?? 'Service',
            'amount'   => (float) ($offer->proposed_price ?? 0),
            'method'   => null,
            'date'     => optional($sr->updated_at)->format('d/m/Y') ?? '—',
            'status'   => $status,
        ];
    }

    private function formatRequest(ServiceRequest $sr): array
    {
        $offer  = $sr->acceptedOffer;
        $name   = $offer?->artisan?->user?->full_name ?? '—';
        $status = $sr->status === 'completed' ? 'completed' : 'pending';

        return [
            'id'       => 'sr-' . $sr->id,
            'client'   => $name,
            'initials' => strtoupper(mb_substr($name, 0, 1)),
            'service'  => $sr->title ?? $sr->serviceType?->name ?? 'Service',
            'amount'   => (float) ($offer?->proposed_price ?? 0),
            'method'   => null,
            'date'     => optional($sr->updated_at)->format('d/m/Y') ?? '—',
            'status'   => $status,
        ];
    }
}
