<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClientReview extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_request_id',
        'artisan_id',
        'client_id',
        'rating',
        'payment_reliability',
    ];

    protected $casts = [
        'rating'              => 'integer',
        'payment_reliability' => 'integer',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    public function serviceRequest(): BelongsTo
    {
        return $this->belongsTo(ServiceRequest::class);
    }

    /** The artisan who wrote this assessment. */
    public function artisan(): BelongsTo
    {
        return $this->belongsTo(Artisan::class);
    }

    /** The client being assessed. */
    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }
}