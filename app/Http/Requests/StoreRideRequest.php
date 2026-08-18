<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreRideRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->isRider();
    }

    public function rules(): array
    {
        return [
            'pickup_location' => ['required', 'string', 'max:255'],
            'dropoff_location' => ['required', 'string', 'max:255'],
            'pickup_latitude' => ['required', 'numeric'],
            'pickup_longitude' => ['required', 'numeric'],
            'dropoff_latitude' => ['required', 'numeric'],
            'dropoff_longitude' => ['required', 'numeric'],
            'scheduled_at' => ['nullable', 'date', 'after:now'],
        ];
    }
}
