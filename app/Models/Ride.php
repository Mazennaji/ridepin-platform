<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ride extends Model
{
    protected $fillable = [
        'rider_id',
        'driver_id',
        'pickup_location',
        'dropoff_location',
        'pickup_latitude',
        'pickup_longitude',
        'dropoff_latitude',
        'dropoff_longitude',
        'fare',
        'distance',
        'status',
        'scheduled_at',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'pickup_latitude' => 'decimal:7',
        'pickup_longitude' => 'decimal:7',
        'dropoff_latitude' => 'decimal:7',
        'dropoff_longitude' => 'decimal:7',
        'fare' => 'decimal:2',
        'distance' => 'decimal:2',
    ];

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    public function transaction()
    {
        return $this->hasOne(Transaction::class);
    }

    public function rating()
    {
        return $this->hasOne(Rating::class);
    }

    public function statusLogs()
    {
        return $this->hasMany(RideStatusLog::class);
    }
}
