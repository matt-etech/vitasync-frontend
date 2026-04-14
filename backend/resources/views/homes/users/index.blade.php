@extends('layouts.app')

@section('content')
    <x-page-header title="{{ $home->name }} Users" description="Manage users who belong to this home and assign their access.">
        <x-slot:action>
            <div class="d-flex flex-wrap gap-2">
                <a class="btn btn-outline-secondary" href="{{ route('homes.index') }}"><i class="fa-solid fa-arrow-left me-1"></i>Homes</a>
                <a class="btn btn-primary" href="{{ route('homes.users.create', $home) }}"><i class="fa-solid fa-plus me-1"></i>New home user</a>
            </div>
        </x-slot:action>
    </x-page-header>

    <div class="card shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>User</th>
                        <th>Role</th>
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
                                    <a class="btn btn-sm btn-outline-secondary" href="{{ route('homes.users.edit', [$home, $user]) }}"><i class="fa-solid fa-pen me-1"></i>Edit</a>
                                    <form method="POST" action="{{ route('homes.users.destroy', [$home, $user]) }}" onsubmit="return confirm('Delete this home user?');">
                                        @csrf
                                        @method('DELETE')
                                        <button class="btn btn-sm btn-outline-danger" type="submit"><i class="fa-solid fa-trash me-1"></i>Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td class="py-5 text-center text-secondary" colspan="5">No users are assigned to this home yet.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-4">{{ $users->links() }}</div>
@endsection
