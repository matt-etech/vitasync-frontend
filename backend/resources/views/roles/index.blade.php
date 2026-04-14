@extends('layouts.app')

@section('content')
    <x-page-header title="Roles" description="Create responsibilities and connect them to permissions.">
        <x-slot:action>
            <a class="btn btn-primary" href="{{ route('roles.create') }}"><i class="fa-solid fa-plus me-1"></i>New role</a>
        </x-slot:action>
    </x-page-header>

    <div class="card shadow-sm">
        <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th>Role</th>
                    <th>Permissions</th>
                    <th>Users</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($roles as $role)
                    <tr>
                        <td>
                            <p class="fw-semibold mb-0">{{ $role->name }}</p>
                            <p class="text-secondary mb-0">{{ $role->description ?: 'No description' }}</p>
                        </td>
                        <td>{{ $role->permissions_count }}</td>
                        <td>{{ $role->users_count }}</td>
                        <td>
                            <div class="d-flex flex-wrap gap-2">
                                <a class="btn btn-sm btn-outline-secondary" href="{{ route('roles.edit', $role) }}"><i class="fa-solid fa-pen me-1"></i>Edit</a>
                                <form method="POST" action="{{ route('roles.destroy', $role) }}" onsubmit="return confirm('Delete this role?');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn btn-sm btn-outline-danger" type="submit"><i class="fa-solid fa-trash me-1"></i>Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td class="py-5 text-center text-secondary" colspan="4">No roles have been created yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
        </div>
    </div>

    <div class="mt-4">{{ $roles->links() }}</div>
@endsection
