<div>
    <div class="mb-3">
        <label class="form-label" for="name">Full name</label>
        <input class="form-control focus-ring-brand" id="name" name="name" value="{{ old('name', $user->name) }}" required>
    </div>

    <div class="mb-3">
        <label class="form-label" for="email">Email address</label>
        <input class="form-control focus-ring-brand" id="email" name="email" type="email" value="{{ old('email', $user->email) }}" required>
    </div>

    <div class="row g-3">
        <div class="col-md-6">
            <label class="form-label" for="password">Password</label>
            <input class="form-control focus-ring-brand" id="password" name="password" type="password" @required($passwordRequired)>
            @unless ($passwordRequired)
                <p class="form-text">Leave blank to keep the current password.</p>
            @endunless
        </div>
        <div class="col-md-6">
            <label class="form-label" for="password_confirmation">Confirm password</label>
            <input class="form-control focus-ring-brand" id="password_confirmation" name="password_confirmation" type="password" @required($passwordRequired)>
        </div>
    </div>

    <fieldset class="mt-4">
        <legend class="h6">Roles</legend>
        <div class="row g-3">
            @forelse ($roles as $role)
                <label class="col-md-6">
                    <span class="d-flex gap-3 border rounded p-3 h-100">
                    <input class="form-check-input mt-1" name="roles[]" type="checkbox" value="{{ $role->id }}" @checked(in_array($role->id, old('roles', $selectedRoles), true))>
                    <span>
                        <span class="d-block fw-medium">{{ $role->name }}</span>
                        <span class="d-block small text-secondary">{{ $role->description ?: 'No description' }}</span>
                    </span>
                    </span>
                </label>
            @empty
                <div class="col-12">
                    <p class="alert alert-warning mb-0">Create roles before assigning them to users.</p>
                </div>
            @endforelse
        </div>
    </fieldset>

    <div class="d-flex flex-wrap gap-2 mt-4">
        <button class="btn btn-primary fw-semibold" type="submit">{{ $submitLabel }}</button>
        <a class="btn btn-outline-secondary fw-semibold" href="{{ route('users.index') }}">Cancel</a>
    </div>
</div>
