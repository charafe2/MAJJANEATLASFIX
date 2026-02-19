<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ArtisanTeamMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'artisan_owner_id',
        'user_id',
        'email',
        'role',
        'can_send_offers',
        'is_active',
    ];

    protected $casts = [
        'can_send_offers' => 'boolean',
        'is_active'       => 'boolean',
    ];

    // ── Relationships ─────────────────────────────────────────────────────

    /** The artisan account that owns this team. */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(Artisan::class, 'artisan_owner_id');
    }

    /** The user account of this team member. */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}