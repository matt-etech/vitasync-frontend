<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $permissions = collect([
            ['name' => 'users.manage', 'description' => 'Create, update, and remove user accounts.'],
            ['name' => 'roles.manage', 'description' => 'Create, update, and remove roles.'],
            ['name' => 'permissions.manage', 'description' => 'Create, update, and remove permissions.'],
        ])->map(fn (array $permission): Permission => Permission::firstOrCreate(
            ['name' => $permission['name']],
            ['description' => $permission['description']],
        ));

        $administrator = Role::firstOrCreate([
            'name' => 'Administrator',
        ], [
            'description' => 'Full access to identity and access control.',
        ]);
        $administrator->permissions()->sync($permissions->pluck('id')->all());

        $user = User::firstOrCreate([
            'email' => 'admin@vitasync.local',
        ], [
            'name' => 'System Administrator',
            'password' => Hash::make('password'),
        ]);
        $user->roles()->syncWithoutDetaching([$administrator->id]);
    }
}
