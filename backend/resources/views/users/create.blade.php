@extends('layouts.app')

@section('content')
    <x-page-header title="New User" description="Create a login account and assign roles." />

    <x-form-errors />

    <form class="card card-body shadow-sm col-lg-8" method="POST" action="{{ route('users.store') }}">
        @csrf
        @include('users.partials.form', ['submitLabel' => 'Create user', 'passwordRequired' => true])
    </form>
@endsection
