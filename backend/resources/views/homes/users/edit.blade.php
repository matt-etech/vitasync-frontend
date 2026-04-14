@extends('layouts.app')

@section('content')
    <x-page-header title="Edit {{ $home->name }} User" description="Update home user details, roles, and direct permissions." />

    <x-form-errors />

    <form class="card card-body shadow-sm" method="POST" action="{{ route('homes.users.update', [$home, $user]) }}">
        @csrf
        @method('PUT')
        @include('homes.users.partials.form', ['submitLabel' => 'Update home user', 'passwordRequired' => false])
    </form>
@endsection
