@extends('layouts.app')

@section('content')
    <x-page-header title="New Home" description="Capture the operational details needed to register a care home." />

    <x-form-errors />

    <form class="card card-body shadow-sm" method="POST" action="{{ route('homes.store') }}" enctype="multipart/form-data">
        @csrf
        @include('homes.partials.form', ['submitLabel' => 'Create home'])
    </form>
@endsection
