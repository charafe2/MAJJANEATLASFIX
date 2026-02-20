<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Appointment extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_id',
        'client_id',
        'service_request_id',
        'title',
        'client_name',
        'client_phone',
        'scheduled_at',
        'duration_minutes',
        'status',
        'rdv_type',
        'city',
        'notes',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function serviceRequest(): BelongsTo
    {
        return $this->belongsTo(ServiceRequest::class);
    }
}
