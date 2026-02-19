<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Payment extends Model
{
    use HasFactory;
    protected $fillable = [
        'payer_id',
        'payee_id',
        'payment_type',
        'service_amount',
        'commission_amount',
        'transaction_fee_amount',
        'total_amount',
        'status',
        'transaction_id',
    ];

    protected $casts = [
        'service_amount'         => 'decimal:2',
        'commission_amount'      => 'decimal:2',
        'transaction_fee_amount' => 'decimal:2',
        'total_amount'           => 'decimal:2',
    ];

    // ── Relations ─────────────────────────────────────────────────────────

    /**
     * The user who made the payment (client paying for a job,
     * or artisan paying for a subscription / boost).
     */
    public function payer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'payer_id');
    }

    /**
     * The user who received the payment.
     */
    public function payee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'payee_id');
    }

    /**
     * The artisan subscription this payment funded (if payment_type = subscription).
     */
    public function artisanSubscription(): HasOne
    {
        return $this->hasOne(ArtisanSubscription::class, 'payment_id');
    }

    public function serviceRequest(): HasOne
    {
        return $this->hasOne(ServiceRequest::class, 'payment_id');
    }

    public function refund(): HasOne
    {
        return $this->hasOne(Refund::class, 'payment_id');
    }
}