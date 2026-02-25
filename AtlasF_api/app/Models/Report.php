<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'reporter_id',
        'reported_id',
        'service_request_id',
        'reason',
        'description',
        'photos',
        'status',
        'review_deadline',
    ];

    protected $casts = [
        'review_deadline' => 'datetime',
        'photos'          => 'array',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    /** User who filed the report. */
    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    /** User being reported. */
    public function reported(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reported_id');
    }
}