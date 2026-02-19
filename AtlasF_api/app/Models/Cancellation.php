<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cancellation extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_request_id',
        'cancelled_by_user_id',
        'hours_before_service',
        'is_penalty_applied',
        'penalty_amount',
    ];

    protected $casts = [
        'is_penalty_applied' => 'boolean',
        'penalty_amount'     => 'decimal:2',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function serviceRequest(): BelongsTo
    {
        return $this->belongsTo(ServiceRequest::class);
    }

    public function cancelledBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'cancelled_by_user_id');
    }
}