<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ArtisanBoostCredit extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_id',
        'boost_duration_hours',
        'source',
        'is_used',
        'expires_at',
    ];

    protected $casts = [
        'is_used'    => 'boolean',
        'expires_at' => 'datetime',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }

    /** The boost that consumed this credit (if used). */
    public function boost(): HasOne
    {
        return $this->hasOne(ArtisanBoost::class, 'boost_credit_id');
    }

    /** Referral reward that generated this credit. */
    public function referral(): HasOne
    {
        return $this->hasOne(Referral::class, 'reward_boost_credit_id');
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    public function isExpired(): bool
    {
        return $this->expires_at !== null && now()->gt($this->expires_at);
    }

    public function isAvailable(): bool
    {
        return ! $this->is_used && ! $this->isExpired();
    }
}