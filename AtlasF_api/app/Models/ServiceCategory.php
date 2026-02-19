<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ServiceCategory extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'icon',
        'is_active',
        'display_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function serviceTypes(): HasMany
    {
        return $this->hasMany(ServiceType::class);
    }

    public function artisans(): HasMany
    {
        return $this->hasMany(Artisan::class, 'service_category_id');
    }

    public function serviceRequests(): HasMany
    {
        return $this->hasMany(ServiceRequest::class, 'service_category_id');
    }

    public function portfolios(): HasMany
    {
        return $this->hasMany(ArtisanPortfolio::class, 'service_category_id');
    }

    public function boosts(): HasMany
    {
        return $this->hasMany(ArtisanBoost::class, 'service_category_id');
    }
}
