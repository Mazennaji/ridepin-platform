<?php

namespace App\Filament\Admin\Resources\DriverProfileResource\Pages;

use App\Filament\Admin\Resources\DriverProfileResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditDriverProfile extends EditRecord
{
    protected static string $resource = DriverProfileResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
