@extends('layouts.app')

@section('content')
    <x-page-header title="Edit Permission" description="Update the permission name or description." />

    <x-form-errors />

    <form class="card card-body shadow-sm col-lg-8" method="POST" action="{{ route('permissions.update', $permission) }}">
        @csrf
        @method('PUT')
        @include('permissions.partials.form', ['submitLabel' => 'Update permission'])
    </form>
@endsection
