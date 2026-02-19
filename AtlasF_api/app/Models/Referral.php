<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Referral extends Model
{
    use HasFactory;

    protected $fillable = [
        'referrer_id',
        'referred_id',
        'referral_code_used',
        'status',
        'reward_boost_credit_id',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    /** User who shared the referral code. */
    public function referrer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'referrer_id');
    }

    /** User who signed up using the code. */
    public function referred(): BelongsTo
    {
        return $this->belongsTo(User::class, 'referred_id');
    }

    /** Boost credit awarded as referral reward (nullable until completed). */
    public function rewardCredit(): BelongsTo
    {
        return $this->belongsTo(ArtisanBoostCredit::class, 'reward_boost_credit_id');
    }
}