<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SubscriptionTier extends Model
{
    protected $fillable = [
        'name',
        'price',
        'max_offers_per_month',
        'max_team_members',
        'is_popular',
    ];

    protected $casts = [
        'price'                => 'decimal:2',
        'max_offers_per_month' => 'integer',
        'max_team_members'     => 'integer',
        'is_popular'           => 'boolean',
    ];

    // ── Relations ─────────────────────────────────────────────────────────

    /**
     * A tier can be assigned to many artisan subscriptions.
     */
    public function artisanSubscriptions(): HasMany
    {
        return $this->hasMany(ArtisanSubscription::class, 'subscription_tier_id');
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    /**
     * Returns true if this tier allows unlimited offers.
     */
    public function isUnlimited(): bool
    {
        return $this->max_offers_per_month < 0;
    }

    /**
     * Returns true if this tier is free.
     */
    public function isFree(): bool
    {
        return $this->price == 0;
    }
}