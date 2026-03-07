<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    protected $fillable = [
        'ride_id',
        'rider_id',
        'driver_id',
        'score',
        'comment',
    ];

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }
}
