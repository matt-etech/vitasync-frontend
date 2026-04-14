@extends('layouts.app')

@section('content')
    <x-page-header title="Edit User" description="Update account details and role assignments." />

    <x-form-errors />

    <form class="card card-body shadow-sm col-lg-8" method="POST" action="{{ route('users.update', $user) }}">
        @csrf
        @method('PUT')
        @include('users.partials.form', ['submitLabel' => 'Update user', 'passwordRequired' => false])
    </form>
@endsection
