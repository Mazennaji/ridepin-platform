<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $userId = auth()->id();

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20', "unique:users,phone,{$userId}"],
            'password' => ['sometimes', 'nullable', 'string', 'min:8', 'confirmed'],

            'license_number' => ['sometimes', 'nullable', 'string', 'max:255'],
            'vehicle_type' => ['sometimes', 'nullable', 'string', 'max:255'],
            'vehicle_model' => ['sometimes', 'nullable', 'string', 'max:255'],
            'plate_number' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }
}
