<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ServiceRequestPhoto extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_request_id',
        'photo_url',
        'display_order',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function serviceRequest(): BelongsTo
    {
        return $this->belongsTo(ServiceRequest::class);
    }
}