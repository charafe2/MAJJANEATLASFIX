<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ArtisanBadge extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_id',
        'badge_type',
        'is_active',
        'earned_at',
    ];

    protected $casts = [
        'is_active'  => 'boolean',
        'earned_at'  => 'datetime',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }
}