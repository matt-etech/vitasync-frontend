@extends('layouts.app')

@section('content')
    <x-page-header title="Edit Home" description="Update home details, logo, and manager assignment." />

    <x-form-errors />

    <form class="card card-body shadow-sm" method="POST" action="{{ route('homes.update', $home) }}" enctype="multipart/form-data">
        @csrf
        @method('PUT')
        @include('homes.partials.form', ['submitLabel' => 'Update home'])
    </form>
@endsection
