<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ArtisanService extends Model
{
    protected $fillable = [
        'artisan_id',
        'service_category_id',
        'service_type',
        'description',
        'diploma_url',
    ];

    public function serviceCategory()
    {
        return $this->belongsTo(ServiceCategory::class);
    }

    public function artisan()
    {
        return $this->belongsTo(Artisan::class);
    }
}
