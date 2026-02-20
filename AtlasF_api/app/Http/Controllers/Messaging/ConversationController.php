<?php

namespace App\Http\Controllers\Messaging;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    // ── LIST: all conversations for the authenticated user ────────────────

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type === 'client') {
            $client = $user->client;
            if (!$client) {
                return response()->json(['error' => 'Client profile not found.'], 404);
            }

            $conversations = Conversation::with([
                'artisan.user',
                'artisan.primaryCategory',
                'messages' => fn ($q) => $q->latest()->limit(1),
            ])
            ->where('client_id', $client->id)
            ->where('status', 'active')
            ->orderByDesc('last_message_at')
            ->get();
        } else {
            $artisan = $user->artisan;
            if (!$artisan) {
                return response()->json(['error' => 'Artisan profile not found.'], 404);
            }

            $conversations = Conversation::with([
                'client.user',
                'messages' => fn ($q) => $q->latest()->limit(1),
            ])
            ->where('artisan_id', $artisan->id)
            ->where('status', 'active')
            ->orderByDesc('last_message_at')
            ->get();
        }

        $result = $conversations->map(function ($conv) use ($user) {
            $latest = $conv->messages->first();
            $unread = $conv->unreadCount($user->id);

            if ($user->account_type === 'client') {
                $other     = $conv->artisan?->user;
                $otherRole = $conv->artisan?->primaryCategory?->name ?? 'Artisan';
            } else {
                $other     = $conv->client?->user;
                $otherRole = 'Client';
            }

            return [
                'id'              => $conv->id,
                'other_name'      => $other?->full_name ?? 'Utilisateur',
                'other_avatar'    => $other?->avatar_url,
                'other_role'      => $otherRole,
                'last_message'    => $latest?->content,
                'last_message_at' => $conv->last_message_at,
                'unread_count'    => $unread,
                'status'          => $conv->status,
            ];
        });

        return response()->json(['data' => $result]);
    }

    // ── CREATE / GET: find or open a conversation ─────────────────────────

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->account_type === 'client') {
            $client = $user->client;
            if (!$client) {
                return response()->json(['error' => 'Client profile not found.'], 404);
            }

            $data = $request->validate([
                'artisan_id'         => 'required|exists:artisans,id',
                'service_request_id' => 'nullable|exists:service_requests,id',
            ]);

            $clientId  = $client->id;
            $artisanId = $data['artisan_id'];

        } else {
            $artisan = $user->artisan;
            if (!$artisan) {
                return response()->json(['error' => 'Artisan profile not found.'], 404);
            }

            $data = $request->validate([
                'client_id'          => 'required|exists:clients,id',
                'service_request_id' => 'nullable|exists:service_requests,id',
            ]);

            $clientId  = $data['client_id'];
            $artisanId = $artisan->id;
        }

        $conv = Conversation::firstOrCreate(
            [
                'client_id'          => $clientId,
                'artisan_id'         => $artisanId,
                'service_request_id' => $data['service_request_id'] ?? null,
            ],
            [
                'status'          => 'active',
                'last_message_at' => now(),
            ]
        );

        return response()->json(['data' => ['id' => $conv->id]], 201);
    }

    // ── SHOW: conversation header info ────────────────────────────────────

    public function show(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();

        if (!$this->isParticipant($user, $conversation)) {
            return response()->json(['error' => 'Unauthorized.'], 403);
        }

        $conversation->load([
            'client.user',
            'artisan.user',
            'artisan.primaryCategory',
        ]);

        if ($user->account_type === 'client') {
            $other     = $conversation->artisan?->user;
            $otherRole = $conversation->artisan?->primaryCategory?->name ?? 'Artisan';
        } else {
            $other     = $conversation->client?->user;
            $otherRole = 'Client';
        }

        return response()->json([
            'data' => [
                'id'           => $conversation->id,
                'other_name'   => $other?->full_name ?? 'Utilisateur',
                'other_avatar' => $other?->avatar_url,
                'other_role'   => $otherRole,
                'status'       => $conversation->status,
            ],
        ]);
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private function isParticipant($user, Conversation $conv): bool
    {
        if ($user->account_type === 'client') {
            return $user->client?->id === $conv->client_id;
        }
        return $user->artisan?->id === $conv->artisan_id;
    }
}
