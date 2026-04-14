@extends('layouts.app')

@section('breadcrumbs')
    <x-breadcrumbs :items="[
        ['label' => 'Workspace', 'url' => route('dashboard')],
        ['label' => 'User Management'],
        ['label' => 'Permissions'],
    ]" />
@endsection

@section('content')
    <x-page-header title="Permissions" description="Define discrete capabilities for role-based access.">
        <x-slot:action>
            <a class="btn btn-primary" href="{{ route('permissions.create') }}"><i class="fa-solid fa-plus me-1"></i>New permission</a>
        </x-slot:action>
    </x-page-header>

    <div class="card shadow-sm">
        <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" data-vitasync-datatable data-export-title="Permissions">
            <thead class="table-light">
                <tr>
                    <th>Permission</th>
                    <th>Roles</th>
                    <th class="no-export">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($permissions as $permission)
                    <tr>
                        <td>
                            <p class="fw-semibold mb-0">{{ $permission->name }}</p>
                            <p class="text-secondary mb-0">{{ $permission->description ?: 'No description' }}</p>
                        </td>
                        <td>{{ $permission->roles_count }}</td>
                        <td>
                            <div class="d-flex flex-wrap gap-2">
                                <a class="btn btn-sm btn-action" href="{{ route('permissions.edit', $permission) }}"><i class="fa-solid fa-pen"></i>Edit</a>
                                <form method="POST" action="{{ route('permissions.destroy', $permission) }}" onsubmit="return confirm('Delete this permission?');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn btn-sm btn-action btn-action-danger" type="submit"><i class="fa-solid fa-trash"></i>Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td class="py-5 text-center text-secondary" colspan="3">No permissions have been created yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
        </div>
    </div>
@endsection
