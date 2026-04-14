<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'VitaSync') }}</title>
    <link href="{{ asset('vendor/bootstrap/bootstrap.min.css') }}" rel="stylesheet">
    <link href="{{ asset('vendor/fontawesome/css/all.min.css') }}" rel="stylesheet">
    <link href="{{ asset('vendor/datatables/css/dataTables.bootstrap5.min.css') }}" rel="stylesheet">
    <link href="{{ asset('vendor/datatables/css/buttons.bootstrap5.min.css') }}" rel="stylesheet">
    <style>
        :root {
            --vitasync-ink: #101828;
            --vitasync-muted: #667085;
            --vitasync-line: #e4e7ec;
            --vitasync-soft-line: #f2f4f7;
            --vitasync-teal: #0f766e;
            --vitasync-teal-dark: #134e4a;
            --vitasync-teal-soft: #ccfbf1;
            --vitasync-surface: #f6f8fb;
            --vitasync-panel: #ffffff;
        }

        body {
            background: var(--vitasync-surface);
            color: var(--vitasync-ink);
            font-size: 15px;
        }

        .btn-primary {
            --bs-btn-bg: var(--vitasync-teal);
            --bs-btn-border-color: var(--vitasync-teal);
            --bs-btn-hover-bg: var(--vitasync-teal-dark);
            --bs-btn-hover-border-color: var(--vitasync-teal-dark);
        }

        .btn,
        .form-control,
        .form-select,
        .dropdown-item {
            border-radius: .5rem;
        }

        .text-brand {
            color: var(--vitasync-teal-dark);
        }

        .app-shell {
            padding: 1.25rem;
        }

        .workspace-header {
            background: rgba(255, 255, 255, .96);
            border: 1px solid var(--vitasync-soft-line);
            border-radius: 1.5rem;
            box-shadow: 0 18px 45px rgba(16, 24, 40, .08);
            overflow: visible;
        }

        .brand-mark {
            width: 3rem;
            height: 3rem;
            border-radius: .5rem;
            object-fit: contain;
        }

        .brand-title {
            font-size: 1.25rem;
            letter-spacing: -.02em;
        }

        .brand-kicker,
        .section-kicker {
            color: var(--vitasync-muted);
            font-size: .76rem;
            font-weight: 700;
            letter-spacing: .16em;
            text-transform: uppercase;
        }

        .account-panel {
            background: #f8fafc;
            border: 1px solid var(--vitasync-soft-line);
            border-radius: 1rem;
            padding: .5rem;
        }

        .avatar-initial {
            width: 2.6rem;
            height: 2.6rem;
            border-radius: .8rem;
            background: #eef2f7;
            color: var(--vitasync-ink);
            font-weight: 800;
        }

        .workspace-nav {
            border-top: 1px solid var(--vitasync-soft-line);
            padding: .85rem 0;
        }

        .workspace-nav .nav-link,
        .workspace-nav .dropdown-toggle {
            border: 1px solid transparent;
            border-radius: .5rem;
            color: #344054;
            font-weight: 700;
            padding: .68rem 1rem;
        }

        .workspace-nav .nav-link:hover,
        .workspace-nav .dropdown-toggle:hover {
            background: #f8fafc;
            border-color: var(--vitasync-line);
            color: var(--vitasync-teal-dark);
        }

        .workspace-nav .nav-link.active,
        .workspace-nav .dropdown-toggle.active {
            background: var(--vitasync-teal-dark);
            color: #fff;
        }

        .mega-menu {
            border: 1px solid var(--vitasync-line);
            border-radius: 1rem;
            box-shadow: 0 26px 60px rgba(16, 24, 40, .14);
            min-width: 21rem;
            padding: .75rem;
        }

        .mega-menu .dropdown-item {
            border-radius: .5rem;
            padding: .9rem;
            white-space: normal;
        }

        .mega-menu .dropdown-item:hover {
            background: #f8fafc;
        }

        .menu-icon {
            width: 1.7rem;
            color: var(--vitasync-muted);
        }

        .content-panel,
        .card {
            border-color: var(--vitasync-line);
            border-radius: 1rem;
            box-shadow: 0 10px 30px rgba(16, 24, 40, .06);
        }

        .page-hero {
            background: rgba(255, 255, 255, .94);
            border: 1px solid var(--vitasync-soft-line);
            border-radius: 1.25rem;
            box-shadow: 0 12px 32px rgba(16, 24, 40, .06);
            padding: 2rem;
        }

        .focus-ring-brand:focus {
            border-color: var(--vitasync-teal);
            box-shadow: 0 0 0 .25rem rgba(17, 94, 89, .15);
        }

        div.dataTables_wrapper div.dataTables_filter input,
        div.dataTables_wrapper div.dataTables_length select {
            border-radius: .5rem;
        }

        .dataTables_wrapper {
            padding: 1.25rem;
        }

        .dataTables_wrapper .dataTables_length label,
        .dataTables_wrapper .dataTables_filter label,
        .dataTables_wrapper .dataTables_info {
            color: #344054;
            font-size: .9rem;
            font-weight: 600;
        }

        .dataTables_wrapper .dataTables_filter input,
        .dataTables_wrapper .dataTables_length select {
            border: 1px solid var(--vitasync-line);
            color: var(--vitasync-ink);
            min-height: 2.35rem;
        }

        .dataTables_wrapper .dataTables_filter input::placeholder {
            color: #667085;
        }

        .dt-buttons .btn {
            background: #fff;
            border: 1px solid #98a2b3;
            color: #1d2939;
            font-weight: 700;
            margin-right: .35rem;
            min-width: 5rem;
        }

        .dataTables_wrapper > .row:first-child {
            margin-bottom: 1rem !important;
        }

        .dataTables_wrapper > .row:last-child {
            border-top: 1px solid var(--vitasync-soft-line);
            margin-top: 1.25rem !important;
            padding-top: 1rem;
        }

        .dataTables_wrapper .dataTables_info {
            padding-top: .35rem !important;
        }

        .dataTables_wrapper .dataTables_paginate .pagination {
            margin-bottom: 0;
        }

        .dt-buttons .btn:hover,
        .dt-buttons .btn:focus {
            background: var(--vitasync-teal-dark);
            border-color: var(--vitasync-teal-dark);
            color: #fff;
        }

        table.dataTable {
            margin-top: .5rem !important;
        }

        table.dataTable thead th {
            background: #eef4f3;
            border-bottom: 1px solid var(--vitasync-line) !important;
            color: #101828;
            font-size: .82rem;
            font-weight: 800;
            letter-spacing: .02em;
            text-transform: none;
        }

        table.dataTable tbody td {
            border-color: var(--vitasync-soft-line);
            color: var(--vitasync-ink);
            vertical-align: middle;
        }

        .page-item .page-link {
            border-color: #98a2b3;
            color: #1d2939;
            font-weight: 700;
        }

        .page-item.active .page-link {
            background: var(--vitasync-teal-dark);
            border-color: var(--vitasync-teal-dark);
            color: #fff;
        }
    </style>
</head>
<body>
    <div class="min-vh-100 app-shell">
        @auth
            <header class="workspace-header">
                <div>
                    <div class="container-fluid px-4 py-3">
                        <div class="d-flex flex-column flex-md-row gap-3 align-items-md-center justify-content-md-between">
                            <div class="d-flex align-items-center gap-3">
                                <img src="{{ asset('logo.png') }}" alt="VitaSync logo" class="brand-mark">
                                <div>
                                    <a href="{{ route('dashboard') }}" class="brand-title fw-bold text-dark text-decoration-none">VitaSync</a>
                                    <p class="brand-kicker mb-0">Default Home</p>
                                </div>
                            </div>
                            <div class="account-panel d-flex flex-wrap align-items-center gap-2">
                                <div class="d-flex align-items-center gap-2 px-2">
                                    <span class="avatar-initial d-inline-flex align-items-center justify-content-center">{{ strtoupper(substr(auth()->user()->name, 0, 1)) }}</span>
                                    <span>
                                        <span class="d-block fw-bold">{{ auth()->user()->name }}</span>
                                        <span class="d-block small text-secondary">Admin{{ auth()->user()->home ? ' - '.auth()->user()->home->name : '' }}</span>
                                    </span>
                                </div>
                                @if (auth()->user()->home)
                                    <a class="btn btn-outline-dark" href="{{ route('homes.users.index', auth()->user()->home) }}">
                                        <i class="fa-solid fa-house me-2"></i>{{ auth()->user()->home->name }}
                                    </a>
                                @elseif (auth()->user()->hasPermission('homes.manage'))
                                    <a class="btn btn-outline-dark" href="{{ route('homes.index') }}">
                                        <i class="fa-solid fa-house me-2"></i>Homes
                                    </a>
                                @endif
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
                                    <button class="btn btn-outline-dark" type="submit">
                                        <i class="fa-solid fa-right-from-bracket me-1"></i>Log out
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <nav class="navbar navbar-expand-lg workspace-nav">
                    <div class="container-fluid px-4">
                        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#primaryNavigation" aria-controls="primaryNavigation" aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="primaryNavigation">
                            <ul class="navbar-nav gap-lg-2 align-items-lg-center">
                                <li class="nav-item">
                                    <a class="nav-link {{ request()->routeIs('dashboard') ? 'active' : '' }}" href="{{ route('dashboard') }}"><i class="fa-solid fa-people-roof me-2"></i>Workspace</a>
                                </li>
                                @if (auth()->user()->hasPermission('homes.manage'))
                                <li class="nav-item">
                                    <a class="nav-link {{ request()->routeIs('homes.*') && ! request()->routeIs('homes.users.*') ? 'active' : '' }}" href="{{ route('homes.index') }}"><i class="fa-solid fa-house-medical me-2"></i>Homes</a>
                                </li>
                                @endif
                                @if (auth()->user()->hasPermission('users.manage') || auth()->user()->hasPermission('roles.manage') || auth()->user()->hasPermission('permissions.manage'))
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle {{ request()->routeIs('users.*') || request()->routeIs('roles.*') || request()->routeIs('permissions.*') || request()->routeIs('homes.users.*') ? 'active' : '' }}" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                        <i class="fa-solid fa-users-gear me-2"></i>User Management
                                    </a>
                                    <ul class="dropdown-menu mega-menu">
                                        <li><span class="dropdown-header section-kicker">Access Operations</span></li>
                                        @if (auth()->user()->hasPermission('users.manage'))
                                        <li>
                                            <a class="dropdown-item d-flex gap-2" href="{{ route('users.index') }}">
                                                <span class="menu-icon"><i class="fa-solid fa-users"></i></span>
                                                <span><span class="d-block fw-bold">Users</span><span class="d-block text-secondary small">Manage global and home-linked accounts.</span></span>
                                            </a>
                                        </li>
                                        @endif
                                        @if (auth()->user()->hasPermission('roles.manage'))
                                        <li>
                                            <a class="dropdown-item d-flex gap-2" href="{{ route('roles.index') }}">
                                                <span class="menu-icon"><i class="fa-solid fa-user-shield"></i></span>
                                                <span><span class="d-block fw-bold">Roles</span><span class="d-block text-secondary small">Group access by responsibility.</span></span>
                                            </a>
                                        </li>
                                        @endif
                                        @if (auth()->user()->hasPermission('permissions.manage'))
                                        <li>
                                            <a class="dropdown-item d-flex gap-2" href="{{ route('permissions.index') }}">
                                                <span class="menu-icon"><i class="fa-solid fa-key"></i></span>
                                                <span><span class="d-block fw-bold">Permissions</span><span class="d-block text-secondary small">Control protected actions.</span></span>
                                            </a>
                                        </li>
                                        @endif
                                    </ul>
                                </li>
                                @endif
                            </ul>
                        </div>
                    </div>
                </nav>
            </header>
        @endauth

        <main class="container-fluid py-4">
            @if (session('status'))
                <div class="alert alert-success">
                    {{ session('status') }}
                </div>
            @endif

            @yield('content')
        </main>
    </div>
    <script src="{{ asset('vendor/jquery/jquery-3.7.1.min.js') }}"></script>
    <script src="{{ asset('vendor/bootstrap/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('vendor/jszip/jszip.min.js') }}"></script>
    <script src="{{ asset('vendor/pdfmake/pdfmake.min.js') }}"></script>
    <script src="{{ asset('vendor/pdfmake/vfs_fonts.js') }}"></script>
    <script src="{{ asset('vendor/datatables/js/jquery.dataTables.min.js') }}"></script>
    <script src="{{ asset('vendor/datatables/js/dataTables.bootstrap5.min.js') }}"></script>
    <script src="{{ asset('vendor/datatables/js/dataTables.buttons.min.js') }}"></script>
    <script src="{{ asset('vendor/datatables/js/buttons.bootstrap5.min.js') }}"></script>
    <script src="{{ asset('vendor/datatables/js/buttons.html5.min.js') }}"></script>
    <script src="{{ asset('vendor/datatables/js/buttons.print.min.js') }}"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('[data-vitasync-datatable]').forEach(function (table) {
                const exportTitle = table.getAttribute('data-export-title') || document.title;

                $(table).DataTable({
                    pageLength: 10,
                    order: [],
                    responsive: true,
                    dom: "<'row align-items-center g-3 mb-3'<'col-lg-6'B><'col-lg-3'l><'col-lg-3'f>>" +
                        "<'row'<'col-12'tr>>" +
                        "<'row align-items-center g-3 mt-3'<'col-md-5'i><'col-md-7'p>>",
                    buttons: [
                        { extend: 'copyHtml5', text: '<i class="fa-regular fa-copy me-1"></i>Copy', className: 'btn btn-sm', exportOptions: { columns: ':not(.no-export)' } },
                        { extend: 'csvHtml5', text: '<i class="fa-solid fa-file-csv me-1"></i>CSV', className: 'btn btn-sm', title: exportTitle, exportOptions: { columns: ':not(.no-export)' } },
                        { extend: 'excelHtml5', text: '<i class="fa-regular fa-file-excel me-1"></i>Excel', className: 'btn btn-sm', title: exportTitle, exportOptions: { columns: ':not(.no-export)' } },
                        { extend: 'pdfHtml5', text: '<i class="fa-regular fa-file-pdf me-1"></i>PDF', className: 'btn btn-sm', title: exportTitle, orientation: 'landscape', pageSize: 'A4', exportOptions: { columns: ':not(.no-export)' } }
                    ],
                    language: {
                        search: '',
                        searchPlaceholder: 'Search records',
                        lengthMenu: 'Show _MENU_',
                    }
                });
            });
        });
    </script>
</body>
</html>
