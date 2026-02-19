<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProfessionalLicense extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_id',
        'license_type',
        'license_number',
        'is_verified',
    ];

    protected $casts = [
        'is_verified' => 'boolean',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }
}