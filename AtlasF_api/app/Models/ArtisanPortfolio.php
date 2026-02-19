<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ArtisanPortfolio extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_id',
        'service_category_id',
        'image_url',
        'title',
        'is_visible',
    ];

    protected $casts = [
        'is_visible' => 'boolean',
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
}