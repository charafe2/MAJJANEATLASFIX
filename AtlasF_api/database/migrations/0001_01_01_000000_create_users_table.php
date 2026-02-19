<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            
            $table->id();

            $table->enum('account_type', ['client', 'artisan']);
            $table->enum('auth_provider', ['email', 'google', 'facebook'])->default('email');
            $table->string('google_id')->unique()->nullable();
            $table->string('facebook_id')->unique()->nullable();
            $table->string('full_name');
            $table->date('birth_date');
            $table->string('email')->unique();
            $table->string('phone', 20)->unique();
            $table->string('avatar_url')->nullable();

            $table->string('password')->nullable();

            $table->enum('verification_method', ['email', 'phone'])->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('phone_verified_at')->nullable();

            $table->string('cin_number')->unique()->nullable();
            $table->boolean('cin_verified')->default(false);
            $table->string('cin_document_url')->nullable();

        
            $table->boolean('is_active')->default(false);
            $table->boolean('is_banned')->default(false);
            $table->text('ban_reason')->nullable();
            $table->timestamp('suspended_until')->nullable();
            $table->integer('suspension_count')->default(0);

            $table->timestamp('last_login')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};