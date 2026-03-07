<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DriverProfile extends Model
{
    protected $fillable = [
        'user_id',
        'license_number',
        'vehicle_type',
        'vehicle_model',
        'plate_number',
        'current_latitude',
        'current_longitude',
        'is_available',
        'verification_status'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
