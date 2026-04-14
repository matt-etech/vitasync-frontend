@extends('layouts.app')

@section('content')
    <x-page-header title="New Permission" description="Create a capability that can be assigned to roles." />

    <x-form-errors />

    <form class="card card-body shadow-sm col-lg-8" method="POST" action="{{ route('permissions.store') }}">
        @csrf
        @include('permissions.partials.form', ['submitLabel' => 'Create permission'])
    </form>
@endsection
