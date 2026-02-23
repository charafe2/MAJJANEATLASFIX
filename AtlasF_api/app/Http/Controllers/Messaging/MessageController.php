<?php

namespace App\Http\Controllers\Messaging;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    // ── LIST: messages in a conversation (oldest first) ───────────────────

    public function index(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();

        if (!$this->isParticipant($user, $conversation)) {
            return response()->json(['error' => 'Unauthorized.'], 403);
        }

        $messages = $conversation->messages()
            ->with('sender:id,full_name,avatar_url')
            ->orderBy('created_at', 'asc')
            ->paginate(50);

        // Mark received messages as read
        $conversation->messages()
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json($messages);
    }

    // ── SEND: post a new message ──────────────────────────────────────────

    public function store(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();

        if (!$this->isParticipant($user, $conversation)) {
            return response()->json(['error' => 'Unauthorized.'], 403);
        }

        if ($conversation->status !== 'active') {
            return response()->json(['error' => 'This conversation is not active.'], 422);
        }

        $data = $request->validate([
            'content'      => 'required|string|max:5000',
            'message_type' => 'nullable|in:text,image,file',
        ]);

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'sender_id'       => $user->id,
            'content'         => $data['content'],
            'message_type'    => $data['message_type'] ?? 'text',
            'is_read'         => false,
        ]);

        $conversation->update(['last_message_at' => now()]);

        // Notify the other participant
        $recipientUserId = $user->account_type === 'client'
            ? $conversation->artisan->user_id
            : $conversation->client->user_id;

        Notification::create([
            'user_id' => $recipientUserId,
            'type'    => 'message',
            'title'   => 'Nouveau message',
            'message' => $user->full_name . ' vous a envoyé un message.',
        ]);

        $message->load('sender:id,full_name,avatar_url');

        return response()->json(['data' => $message], 201);
    }

    // ── MARK READ: mark all received messages as read ─────────────────────

    public function markRead(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();

        if (!$this->isParticipant($user, $conversation)) {
            return response()->json(['error' => 'Unauthorized.'], 403);
        }

        $conversation->messages()
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['message' => 'Messages marked as read.']);
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
