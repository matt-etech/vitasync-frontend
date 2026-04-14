@extends('layouts.app')

@section('content')
    <x-page-header title="New Role" description="Define a role and assign existing permissions." />

    <x-form-errors />

    <form class="card card-body shadow-sm col-lg-8" method="POST" action="{{ route('roles.store') }}">
        @csrf
        @include('roles.partials.form', ['submitLabel' => 'Create role'])
    </form>
@endsection
