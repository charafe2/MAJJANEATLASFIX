<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('professional_licenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->string('license_type', 100);
            $table->string('license_number', 100);
            $table->boolean('is_verified')->default(false);
            $table->timestamps();

            $table->index('artisan_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('professional_licenses');
    }
};
