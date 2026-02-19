<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Artisan extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'service_category_id',
        'current_subscription_tier_id',
        'business_name',
        'bio',
        'experience_years',
        'city',
        'address',
        'referral_code',
        'referred_by_id',
        'rating_average',
        'total_reviews',
        'total_jobs_completed',
        'total_revenue',
        'response_time_avg',
        'confidence_score',
        'is_available',
        'is_verified',
        'profile_completed',
        'subscription_expires_at',
    ];

    protected $casts = [
        'rating_average'          => 'decimal:2',
        'total_revenue'           => 'decimal:2',
        'confidence_score'        => 'decimal:2',
        'is_available'            => 'boolean',
        'is_verified'             => 'boolean',
        'profile_completed'       => 'boolean',
        'subscription_expires_at' => 'datetime',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(ArtisanSubscription::class, 'artisan_id');
    }

    public function activeSubscription(): HasOne
    {
        return $this->hasOne(ArtisanSubscription::class, 'artisan_id')
                    ->where('status', 'active')
                    ->latest('start_date');
    }

    public function referredBy(): BelongsTo
    {
        return $this->belongsTo(Artisan::class, 'referred_by_id');
    }

    public function referrals(): HasMany
    {
        return $this->hasMany(Artisan::class, 'referred_by_id');
    }

    public function primaryCategory(): BelongsTo
    {
        return $this->belongsTo(ServiceCategory::class, 'service_category_id');
    }

    public function currentTier(): BelongsTo
    {
        return $this->belongsTo(SubscriptionTier::class, 'current_subscription_tier_id');
    }

    // ── Profile details ───────────────────────────────────────────────────

    public function licenses(): HasMany
    {
        return $this->hasMany(ProfessionalLicense::class);
    }

    public function certifications(): HasMany
    {
        return $this->hasMany(ArtisanCertification::class);
    }

    public function badges(): HasMany
    {
        return $this->hasMany(ArtisanBadge::class);
    }

    public function portfolio(): HasMany
    {
        return $this->hasMany(ArtisanPortfolio::class);
    }

    public function teamMembers(): HasMany
    {
        return $this->hasMany(ArtisanTeamMember::class, 'artisan_owner_id');
    }

    // ── Boosts & credits ─────────────────────────────────────────────────

    public function boostCredits(): HasMany
    {
        return $this->hasMany(ArtisanBoostCredit::class);
    }

    public function boosts(): HasMany
    {
        return $this->hasMany(ArtisanBoost::class);
    }

    public function activeBoost(): HasOne
    {
        return $this->hasOne(ArtisanBoost::class)
                    ->where('is_active', true)
                    ->where('end_date', '>=', now());
    }

    // ── Service requests & offers ─────────────────────────────────────────

    public function offers(): HasMany
    {
        return $this->hasMany(ArtisanOffer::class);
    }

    public function directRequests(): HasMany
    {
        return $this->hasMany(ServiceRequest::class, 'target_artisan_id');
    }

    // ── Reviews ───────────────────────────────────────────────────────────

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function clientReviewsGiven(): HasMany
    {
        return $this->hasMany(ClientReview::class);
    }

    // ── Conversations ─────────────────────────────────────────────────────

    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class);
    }
}