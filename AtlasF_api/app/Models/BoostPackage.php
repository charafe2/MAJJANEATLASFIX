<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BoostPackage extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'duration_hours',
        'price',
        'is_popular',
    ];

    protected $casts = [
        'price'      => 'decimal:2',
        'is_popular' => 'boolean',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function boosts(): HasMany
    {
        return $this->hasMany(ArtisanBoost::class, 'boost_package_id');
    }
}