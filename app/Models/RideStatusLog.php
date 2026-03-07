<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RideStatusLog extends Model
{
    protected $fillable = [
        'ride_id',
        'status',
        'changed_by',
        'timestamp',
    ];

    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'timestamp' => 'datetime',
        ];
    }

    public function ride()
    {
        return $this->belongsTo(Ride::class);
    }

    public function changedBy()
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
