<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_certifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_id')->constrained('artisans')->cascadeOnDelete();
            $table->string('title', 150);
            $table->string('document_url')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->timestamps();

            $table->index('artisan_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_certifications');
    }
};
