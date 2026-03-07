<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role_id',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function driverProfile()
    {
        return $this->hasOne(DriverProfile::class);
    }

    public function ridesAsRider()
    {
        return $this->hasMany(Ride::class, 'rider_id');
    }

    public function ridesAsDriver()
    {
        return $this->hasMany(Ride::class, 'driver_id');
    }

    public function isAdmin(): bool
    {
        return optional($this->role)->name === 'admin';
    }

    public function isRider(): bool
    {
        return optional($this->role)->name === 'rider';
    }

    public function isDriver(): bool
    {
        return optional($this->role)->name === 'driver';
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function ratingsGiven()
    {
        return $this->hasMany(Rating::class, 'rider_id');
    }

    public function ratingsReceived()
    {
        return $this->hasMany(Rating::class, 'driver_id');
    }
}
