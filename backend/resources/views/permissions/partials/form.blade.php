<div>
    <div class="mb-3">
        <label class="form-label" for="name">Permission name</label>
        <input class="form-control focus-ring-brand" id="name" name="name" value="{{ old('name', $permission->name) }}" required>
    </div>

    <div class="mb-3">
        <label class="form-label" for="description">Description</label>
        <textarea class="form-control focus-ring-brand" id="description" name="description" rows="3">{{ old('description', $permission->description) }}</textarea>
    </div>

    <div class="d-flex flex-wrap gap-2 mt-4">
        <button class="btn btn-primary fw-semibold" type="submit">{{ $submitLabel }}</button>
        <a class="btn btn-outline-secondary fw-semibold" href="{{ route('permissions.index') }}">Cancel</a>
    </div>
</div>
