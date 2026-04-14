<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'VitaSync') }}</title>
    <link href="{{ asset('vendor/bootstrap/bootstrap.min.css') }}" rel="stylesheet">
    <link href="{{ asset('vendor/fontawesome/css/all.min.css') }}" rel="stylesheet">
    <style>
        :root {
            --vitasync-teal: #115e59;
            --vitasync-teal-dark: #134e4a;
            --vitasync-surface: #f8fafc;
        }

        body {
            background: var(--vitasync-surface);
        }

        .btn-primary {
            --bs-btn-bg: var(--vitasync-teal);
            --bs-btn-border-color: var(--vitasync-teal);
            --bs-btn-hover-bg: var(--vitasync-teal-dark);
            --bs-btn-hover-border-color: var(--vitasync-teal-dark);
        }

        .text-brand {
            color: var(--vitasync-teal-dark);
        }

        .focus-ring-brand:focus {
            border-color: var(--vitasync-teal);
            box-shadow: 0 0 0 .25rem rgba(17, 94, 89, .15);
        }
    </style>
</head>
<body>
    <div class="min-vh-100">
        @auth
            <header class="border-bottom bg-white">
                <div class="container py-3">
                    <div class="d-flex flex-column flex-md-row gap-3 align-items-md-center justify-content-md-between">
                    <div>
                        <a href="{{ route('dashboard') }}" class="h4 mb-0 fw-semibold text-brand text-decoration-none">VitaSync</a>
                        <p class="mb-0 small text-secondary">Identity and access control</p>
                    </div>
                    <nav class="d-flex flex-wrap align-items-center gap-2">
                        <a class="btn btn-sm btn-outline-secondary" href="{{ route('dashboard') }}"><i class="fa-solid fa-gauge me-1"></i>Dashboard</a>
                        <a class="btn btn-sm btn-outline-secondary" href="{{ route('users.index') }}"><i class="fa-solid fa-users me-1"></i>Users</a>
                        <a class="btn btn-sm btn-outline-secondary" href="{{ route('roles.index') }}"><i class="fa-solid fa-user-shield me-1"></i>Roles</a>
                        <a class="btn btn-sm btn-outline-secondary" href="{{ route('permissions.index') }}"><i class="fa-solid fa-key me-1"></i>Permissions</a>
                        <form method="POST" action="{{ route('logout') }}">
                            @csrf
                            <button class="btn btn-sm btn-outline-danger" type="submit"><i class="fa-solid fa-right-from-bracket me-1"></i>Log out</button>
                        </form>
                    </nav>
                    </div>
                </div>
            </header>
        @endauth

        <main class="container py-4">
            @if (session('status'))
                <div class="alert alert-success">
                    {{ session('status') }}
                </div>
            @endif

            @yield('content')
        </main>
    </div>
    <script src="{{ asset('vendor/bootstrap/bootstrap.bundle.min.js') }}"></script>
</body>
</html>
