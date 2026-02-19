<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ArtisanSubscription extends Model
{
   protected $fillable = [
    'artisan_id',
    'subscription_tier_id',
    'start_date',
    'end_date',
    'status',
    'payment_id',
];

    protected $casts = [
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    // ── Relations ─────────────────────────────────────────────────────────

    /**
     * The artisan this subscription belongs to.
     */
    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class, 'artisan_id');
    }

    /**
     * The tier (basic / pro / premium / business) for this subscription.
     */
    public function tier(): BelongsTo
    {
        return $this->belongsTo(SubscriptionTier::class, 'subscription_tier_id');
    }

    /**
     * The payment that funded this subscription (null for free/basic).
     */
    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class, 'payment_id');
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    /**
     * Is this subscription currently active?
     */
    public function isActive(): bool
    {
        if ($this->status !== 'active') {
            return false;
        }

        // No end_date = indefinite (e.g. basic/free)
        if (is_null($this->end_date)) {
            return true;
        }

        return now()->lte($this->end_date);
    }
}