<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            $table->unsignedBigInteger('service_request_id')->nullable()->after('reported_id');
            $table->json('photos')->nullable()->after('description');

            $table->foreign('service_request_id')
                  ->references('id')->on('service_requests')
                  ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('reports', function (Blueprint $table) {
            $table->dropForeign(['service_request_id']);
            $table->dropColumn(['service_request_id', 'photos']);
        });
    }
};
