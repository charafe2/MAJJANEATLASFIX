<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artisan_team_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('artisan_owner_id')->constrained('artisans')->cascadeOnDelete();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('email', 150);
            $table->string('role', 50);
            $table->boolean('can_send_offers')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('artisan_owner_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('artisan_team_members');
    }
};
