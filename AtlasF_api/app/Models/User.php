<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $fillable = [
        'account_type',
        'auth_provider',
        'google_id',
        'facebook_id',
        'full_name',
        'birth_date',
        'email',
        'phone',
        'avatar_url',
        'password',
        'verification_method',
        'email_verified_at',
        'phone_verified_at',
        'cin_number',
        'cin_verified',
        'cin_document_url',
        'is_active',
        'is_banned',
        'ban_reason',
        'suspended_until',
        'suspension_count',
        'last_login',
    ];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'birth_date'         => 'date',
        'email_verified_at'  => 'datetime',
        'phone_verified_at'  => 'datetime',
        'suspended_until'    => 'datetime',
        'last_login'         => 'datetime',
        'cin_verified'       => 'boolean',
        'is_active'          => 'boolean',
        'is_banned'          => 'boolean',
    ];

    // ── Profile ───────────────────────────────────────────────────────────

    public function client(): HasOne
    {
        return $this->hasOne(Client::class);
    }

    public function artisan(): HasOne
    {
        return $this->hasOne(Artisan::class);
    }

    // ── Preferences & settings ────────────────────────────────────────────

    public function notificationPreferences(): HasOne
    {
        return $this->hasOne(NotificationPreference::class);
    }

    public function savedPaymentMethods(): HasMany
    {
        return $this->hasMany(SavedPaymentMethod::class);
    }

    // ── Notifications ─────────────────────────────────────────────────────

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    // ── Referrals ─────────────────────────────────────────────────────────

    public function referralsSent(): HasMany
    {
        return $this->hasMany(Referral::class, 'referrer_id');
    }

    public function referralReceived(): HasOne
    {
        return $this->hasOne(Referral::class, 'referred_id');
    }

    // ── Payments ─────────────────────────────────────────────────────────

    public function paymentsMade(): HasMany
    {
        return $this->hasMany(Payment::class, 'payer_id');
    }

    public function paymentsReceived(): HasMany
    {
        return $this->hasMany(Payment::class, 'payee_id');
    }

    // ── Moderation ────────────────────────────────────────────────────────

    public function reportsFiled(): HasMany
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    public function reportsReceived(): HasMany
    {
        return $this->hasMany(Report::class, 'reported_id');
    }

    // ── Team / messaging / timeline ───────────────────────────────────────

    public function teamMembership(): HasOne
    {
        return $this->hasOne(ArtisanTeamMember::class);
    }

    public function messagesSent(): HasMany
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    public function triggeredEvents(): HasMany
    {
        return $this->hasMany(ServiceTimeline::class, 'triggered_by_user_id');
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    public function isVerified(): bool
    {
        return $this->email_verified_at !== null || $this->phone_verified_at !== null;
    }

    public function isSuspended(): bool
    {
        return $this->suspended_until !== null && now()->lt($this->suspended_until);
    }

    public function getProfileAttribute()
    {
        return $this->account_type === 'client' ? $this->client : $this->artisan;
    }
}
