@extends('layouts.app')

@section('content')
    <x-page-header title="New {{ $home->name }} User" description="Create a user directly under this home and assign access." />

    <x-form-errors />

    <form class="card card-body shadow-sm" method="POST" action="{{ route('homes.users.store', $home) }}">
        @csrf
        @include('homes.users.partials.form', ['submitLabel' => 'Create home user', 'passwordRequired' => true])
    </form>
@endsection
