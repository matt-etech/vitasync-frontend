<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('client_assessments', function (Blueprint $table) {
            $table->unsignedInteger('version')->default(1)->after('client_id');
            $table->dropUnique(['client_id']);
            $table->unique(['client_id', 'version']);
            $table->index(['client_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('client_assessments', function (Blueprint $table) {
            $table->dropIndex(['client_id', 'status']);
            $table->dropUnique(['client_id', 'version']);
            $table->dropColumn('version');
            $table->unique('client_id');
        });
    }
};
