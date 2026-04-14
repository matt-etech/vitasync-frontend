@extends('layouts.app')

@section('content')
    <x-page-header title="Edit Role" description="Update role details and permission assignments." />

    <x-form-errors />

    <form class="card card-body shadow-sm col-lg-8" method="POST" action="{{ route('roles.update', $role) }}">
        @csrf
        @method('PUT')
        @include('roles.partials.form', ['submitLabel' => 'Update role'])
    </form>
@endsection
