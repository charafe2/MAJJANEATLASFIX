<?php

namespace App\Http\Controllers\Messaging;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

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

        // Transform image_url to full URL
        $messages->getCollection()->transform(function ($msg) {
            if ($msg->image_url) {
                $msg->image_url = Storage::url($msg->image_url);
            }
            return $msg;
        });

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
            'content' => 'nullable|string|max:5000',
            'image'   => 'nullable|image|mimes:jpeg,png,gif,webp|max:5120',
        ]);

        // Must have content or image
        if (empty($data['content']) && !$request->hasFile('image')) {
            return response()->json(['error' => 'Content or image is required.'], 422);
        }

        $imagePath   = null;
        $messageType = 'text';

        if ($request->hasFile('image')) {
            $imagePath   = $request->file('image')->store('message-images', 'public');
            $messageType = 'image';
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'sender_id'       => $user->id,
            'content'         => $data['content'] ?? null,
            'image_url'       => $imagePath,
            'message_type'    => $messageType,
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
            'message' => $user->full_name . ($messageType === 'image' ? ' vous a envoyé une image.' : ' vous a envoyé un message.'),
        ]);

        $message->load('sender:id,full_name,avatar_url');

        // Return full image URL
        if ($message->image_url) {
            $message->image_url = Storage::url($message->image_url);
        }

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
