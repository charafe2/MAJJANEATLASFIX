<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ServiceRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_id',
        'service_category_id',
        'service_type_id',
        'title',
        'description',
        'city',
        'budget_min',
        'budget_max',
        'status',
        'accepted_offer_id',
        'payment_id',
        'request_type',
        'service_mode',
        'notes',
        'target_artisan_id',
    ];

    protected $casts = [
        'budget_min' => 'decimal:2',
        'budget_max' => 'decimal:2',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(ServiceCategory::class, 'service_category_id');
    }

    public function serviceType(): BelongsTo
    {
        return $this->belongsTo(ServiceType::class, 'service_type_id');
    }

    /** The accepted artisan offer (nullable until one is chosen). */
    public function acceptedOffer(): BelongsTo
    {
        return $this->belongsTo(ArtisanOffer::class, 'accepted_offer_id');
    }

    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }

    /** Artisan targeted for a direct request (nullable for public requests). */
    public function targetArtisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class, 'target_artisan_id');
    }

    public function photos(): HasMany
    {
        return $this->hasMany(ServiceRequestPhoto::class);
    }

    public function offers(): HasMany
    {
        return $this->hasMany(ArtisanOffer::class);
    }

    public function timeline(): HasMany
    {
        return $this->hasMany(ServiceTimeline::class);
    }

    public function cancellation(): HasOne
    {
        return $this->hasOne(Cancellation::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function clientReviews(): HasMany
    {
        return $this->hasMany(ClientReview::class);
    }

    public function conversation(): HasOne
    {
        return $this->hasOne(Conversation::class);
    }

    public function refund(): HasOne
    {
        return $this->hasOne(Refund::class);
    }
}