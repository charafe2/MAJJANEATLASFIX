<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ArtisanOffer extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_request_id',
        'artisan_id',
        'proposed_price',
        'estimated_duration',
        'description',
        'status',
        'has_active_boost',
    ];

    protected $casts = [
        'proposed_price'   => 'decimal:2',
        'has_active_boost' => 'boolean',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function serviceRequest(): BelongsTo
    {
        return $this->belongsTo(ServiceRequest::class);
    }

    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }

    /** The service request that accepted this offer (if any). */
    public function acceptedByRequest(): HasOne
    {
        return $this->hasOne(ServiceRequest::class, 'accepted_offer_id');
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    public function isAccepted(): bool
    {
        return $this->status === 'accepted';
    }
}