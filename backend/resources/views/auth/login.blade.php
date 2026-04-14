@extends('layouts.app')

@section('content')
    <div class="row min-vh-100 align-items-center g-5">
        <section class="col-lg-7">
            <img src="{{ asset('logo.png') }}" alt="VitaSync logo" class="mb-4" style="width: 4.5rem; height: 4.5rem; object-fit: contain;">
            <p class="mb-3 small fw-semibold text-uppercase text-brand">VitaSync Access Control</p>
            <h1 class="display-6 fw-semibold">Sign in to manage care platform access safely.</h1>
            <p class="mt-3 lead text-secondary">
                Use this secure entry point to manage users, roles, and permissions for accountable care operations.
            </p>
        </section>

        <section class="col-lg-5">
            <div class="card shadow-sm">
                <div class="card-body p-4">
            <h2 class="h3 fw-semibold">Login</h2>
            <p class="text-secondary">Enter your administrator credentials.</p>

            <form class="mt-4" method="POST" action="{{ route('login.store') }}">
                @csrf

                <div class="mb-3">
                    <label class="form-label" for="email">Email address</label>
                    <input
                        class="form-control focus-ring-brand"
                        id="email"
                        name="email"
                        type="email"
                        value="{{ old('email') }}"
                        autocomplete="email"
                        required
                        autofocus
                    >
                    @error('email')
                        <p class="mt-2 small text-danger">{{ $message }}</p>
                    @enderror
                </div>

                <div class="mb-3">
                    <label class="form-label" for="password">Password</label>
                    <input
                        class="form-control focus-ring-brand"
                        id="password"
                        name="password"
                        type="password"
                        autocomplete="current-password"
                        required
                    >
                    @error('password')
                        <p class="mt-2 small text-danger">{{ $message }}</p>
                    @enderror
                </div>

                <label class="form-check mb-4">
                    <input class="form-check-input" name="remember" type="checkbox" value="1">
                    <span class="form-check-label">
                    Remember this device
                    </span>
                </label>

                <button class="btn btn-primary w-100 fw-semibold" type="submit">
                    Sign in
                </button>
            </form>
                </div>
            </div>
        </section>
    </div>
@endsection
