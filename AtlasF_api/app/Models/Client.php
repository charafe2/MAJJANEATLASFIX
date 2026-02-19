<?php
// app/Models/Client.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Client extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'city',
        'address',
        'total_requests',
        'total_spent',
        'reliability_score',
        'profile_completed',
    ];

    protected $casts = [
        'total_spent'       => 'decimal:2',
        'reliability_score' => 'decimal:2',
        'profile_completed' => 'boolean',
    ];

    // --------------------------------------------------------
    // RELATIONSHIPS
    // --------------------------------------------------------

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function serviceRequests(): HasMany
    {
        return $this->hasMany(ServiceRequest::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function clientReviewsReceived(): HasMany
    {
        return $this->hasMany(ClientReview::class);
    }

    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class);
    }
}