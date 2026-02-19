<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ArtisanBoost extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_id',
        'service_category_id',
        'boost_package_id',
        'boost_credit_id',
        'boost_type',
        'start_date',
        'end_date',
        'is_active',
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date'   => 'datetime',
        'is_active'  => 'boolean',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(ServiceCategory::class, 'service_category_id');
    }

    /** The paid package that funded this boost (null when paid by credit). */
    public function package(): BelongsTo
    {
        return $this->belongsTo(BoostPackage::class, 'boost_package_id');
    }

    /** The credit that funded this boost (null when paid by cash). */
    public function credit(): BelongsTo
    {
        return $this->belongsTo(ArtisanBoostCredit::class, 'boost_credit_id');
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    public function isLive(): bool
    {
        return $this->is_active
            && now()->between($this->start_date, $this->end_date);
    }
}