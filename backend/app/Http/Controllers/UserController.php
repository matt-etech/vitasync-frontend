<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Models\Home;
use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Arr;
use Illuminate\View\View;

class UserController extends Controller
{
    public function index(): View
    {
        return view('users.index', [
            'users' => User::with(['home', 'roles', 'permissions'])->orderBy('name')->paginate(10),
        ]);
    }

    public function create(): View
    {
        return view('users.create', [
            'user' => new User(),
            'homes' => Home::orderBy('name')->get(),
            'roles' => Role::orderBy('name')->get(),
            'permissions' => Permission::orderBy('name')->get(),
            'selectedRoles' => [],
            'selectedPermissions' => [],
        ]);
    }

    public function store(StoreUserRequest $request): RedirectResponse
    {
        $validated = $request->validated();
        $attributes = Arr::only($validated, ['name', 'email', 'password', 'home_id', 'job_title', 'phone']);
        $attributes['is_active'] = $request->boolean('is_active', true);

        $user = User::create($attributes);
        $user->roles()->sync($validated['roles'] ?? []);
        $user->permissions()->sync($validated['permissions'] ?? []);

        return redirect()->route('users.index')->with('status', 'User created.');
    }

    public function edit(User $user): View
    {
        $user->load(['roles', 'permissions']);

        return view('users.edit', [
            'user' => $user,
            'homes' => Home::orderBy('name')->get(),
            'roles' => Role::orderBy('name')->get(),
            'permissions' => Permission::orderBy('name')->get(),
            'selectedRoles' => $user->roles->pluck('id')->all(),
            'selectedPermissions' => $user->permissions->pluck('id')->all(),
        ]);
    }

    public function update(UpdateUserRequest $request, User $user): RedirectResponse
    {
        $validated = $request->validated();
        $attributes = Arr::only($validated, ['name', 'email', 'home_id', 'job_title', 'phone']);
        $attributes['is_active'] = $request->boolean('is_active');

        if (! empty($validated['password'])) {
            $attributes['password'] = $validated['password'];
        }

        $user->update($attributes);
        $user->roles()->sync($validated['roles'] ?? []);
        $user->permissions()->sync($validated['permissions'] ?? []);

        return redirect()->route('users.index')->with('status', 'User updated.');
    }

    public function destroy(User $user): RedirectResponse
    {
        $user->delete();

        return redirect()->route('users.index')->with('status', 'User deleted.');
    }
}
