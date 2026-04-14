@extends('layouts.app')

@section('content')
    <x-page-header title="Users" description="Create accounts and assign operational roles.">
        <x-slot:action>
            <a class="btn btn-primary" href="{{ route('users.create') }}"><i class="fa-solid fa-plus me-1"></i>New user</a>
        </x-slot:action>
    </x-page-header>

    <div class="card shadow-sm">
        <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>User</th>
                    <th>Home</th>
                    <th>Roles</th>
                    <th>Direct permissions</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($users as $user)
                    <tr>
                        <td>
                            <p class="fw-semibold mb-0">{{ $user->name }}</p>
                            <p class="text-secondary mb-0">{{ $user->email }}</p>
                            @if ($user->job_title)
                                <p class="small text-secondary mb-0">{{ $user->job_title }}</p>
                            @endif
                        </td>
                        <td>
                            @if ($user->home)
                                <a href="{{ route('homes.users.index', $user->home) }}">{{ $user->home->name }}</a>
                            @else
                                <span class="text-secondary">Platform-wide</span>
                            @endif
                        </td>
                        <td>
                            @forelse ($user->roles as $role)
                                <span class="badge text-bg-light border me-1">{{ $role->name }}</span>
                            @empty
                                <span class="text-secondary">No roles assigned</span>
                            @endforelse
                        </td>
                        <td>{{ $user->permissions->count() }}</td>
                        <td><span class="badge text-bg-{{ $user->is_active ? 'success' : 'secondary' }}">{{ $user->is_active ? 'Active' : 'Inactive' }}</span></td>
                        <td>
                            <div class="d-flex flex-wrap gap-2">
                                <a class="btn btn-sm btn-outline-secondary" href="{{ route('users.edit', $user) }}"><i class="fa-solid fa-pen me-1"></i>Edit</a>
                                <form method="POST" action="{{ route('users.destroy', $user) }}" onsubmit="return confirm('Delete this user?');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn btn-sm btn-outline-danger" type="submit"><i class="fa-solid fa-trash me-1"></i>Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td class="py-5 text-center text-secondary" colspan="6">No users have been created yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
        </div>
    </div>

    <div class="mt-4">{{ $users->links() }}</div>
@endsection
