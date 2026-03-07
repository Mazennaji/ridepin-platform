<?php

namespace App\Filament\Admin\Resources\DriverProfileResource\Pages;

use App\Filament\Admin\Resources\DriverProfileResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListDriverProfiles extends ListRecords
{
    protected static string $resource = DriverProfileResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
