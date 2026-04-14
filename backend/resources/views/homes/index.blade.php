@extends('layouts.app')

@section('content')
    <x-page-header title="Homes" description="Create care homes, assign managers, and manage home users.">
        <x-slot:action>
            <a class="btn btn-primary" href="{{ route('homes.create') }}"><i class="fa-solid fa-plus me-1"></i>New home</a>
        </x-slot:action>
    </x-page-header>

    <div class="card shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" data-vitasync-datatable data-export-title="Homes">
                <thead class="table-light">
                    <tr>
                        <th>Home</th>
                        <th>Manager</th>
                        <th>Users</th>
                        <th>Status</th>
                        <th class="no-export">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($homes as $home)
                        <tr>
                            <td>
                                <div class="d-flex align-items-center gap-3">
                                    @if ($home->logoUrl())
                                        <img src="{{ $home->logoUrl() }}" alt="{{ $home->name }} logo" class="rounded border" width="48" height="48">
                                    @else
                                        <span class="d-inline-flex align-items-center justify-content-center rounded border bg-light" style="width:48px;height:48px;">
                                            <i class="fa-solid fa-house-medical text-secondary"></i>
                                        </span>
                                    @endif
                                    <div>
                                        <p class="fw-semibold mb-0">{{ $home->name }}</p>
                                        <p class="text-secondary mb-0">{{ $home->city }}, {{ $home->postcode }}</p>
                                    </div>
                                </div>
                            </td>
                            <td>{{ $home->manager?->name ?: 'Not assigned' }}</td>
                            <td>{{ $home->users_count }}</td>
                            <td><span class="badge text-bg-{{ $home->status === 'active' ? 'success' : ($home->status === 'onboarding' ? 'warning' : 'secondary') }}">{{ ucfirst($home->status) }}</span></td>
                            <td>
                                <div class="d-flex flex-wrap gap-2">
                                    <a class="btn btn-sm btn-outline-primary" href="{{ route('homes.users.index', $home) }}"><i class="fa-solid fa-users me-1"></i>Users</a>
                                    <a class="btn btn-sm btn-outline-secondary" href="{{ route('homes.edit', $home) }}"><i class="fa-solid fa-pen me-1"></i>Edit</a>
                                    <form method="POST" action="{{ route('homes.destroy', $home) }}" onsubmit="return confirm('Delete this home? Users will be detached from it.');">
                                        @csrf
                                        @method('DELETE')
                                        <button class="btn btn-sm btn-outline-danger" type="submit"><i class="fa-solid fa-trash me-1"></i>Delete</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td class="py-5 text-center text-secondary" colspan="5">No homes have been created yet.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
