<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // PostgreSQL stores Laravel enums as CHECK constraints.
        // Drop the existing constraint and recreate it with 'boost' added.
        DB::statement("ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check");

        DB::statement("
            ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
            CHECK (type IN (
                'new_offer','offer_accepted','payment','review',
                'message','system','cancellation','boost'
            ))
        ");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check");

        DB::statement("
            ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
            CHECK (type IN (
                'new_offer','offer_accepted','payment','review',
                'message','system','cancellation'
            ))
        ");
    }
};
