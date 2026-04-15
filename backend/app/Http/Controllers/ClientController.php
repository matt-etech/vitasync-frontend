<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreClientRequest;
use App\Http\Requests\UpdateClientRequest;
use App\Models\Client;
use App\Models\Home;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class ClientController extends Controller
{
    public function index(): View
    {
        return view('clients.index', [
            'clients' => Client::with(['home', 'assessment'])->orderBy('last_name')->orderBy('first_name')->get(),
            'newClient' => new Client(['status' => 'active', 'onboarding_status' => Client::ONBOARDING_STATUS_ONBOARDING]),
            'homes' => Home::where('status', 'active')->orderBy('name')->get(),
        ]);
    }

    public function create(): View
    {
        return view('clients.create', [
            'client' => new Client(['status' => 'active', 'onboarding_status' => Client::ONBOARDING_STATUS_ONBOARDING]),
            'homes' => Home::where('status', 'active')->orderBy('name')->get(),
        ]);
    }

    public function show(Client $client): View
    {
        return view('clients.show', [
            'client' => $client->load([
                'home',
                'reviewer',
                'assessments' => fn ($query) => $query
                    ->with([
                        'reviewer',
                        'needs',
                        'functional',
                        'medical',
                        'mentalCapacity',
                        'risk',
                        'communication',
                        'equality',
                        'social',
                        'environmental',
                    ])
                    ->latest('version'),
            ]),
        ]);
    }

    public function store(StoreClientRequest $request): RedirectResponse
    {
        $client = Client::create(array_merge($request->validated(), [
            'onboarding_status' => Client::ONBOARDING_STATUS_ONBOARDING,
        ]));

        return redirect()->route('clients.assessments.edit', $client)->with('status', 'Client created. Complete onboarding assessments before submission.');
    }

    public function edit(Client $client): View
    {
        return view('clients.edit', [
            'client' => $client,
            'homes' => Home::where('status', 'active')->orWhere('id', $client->home_id)->orderBy('name')->get(),
        ]);
    }

    public function update(UpdateClientRequest $request, Client $client): RedirectResponse
    {
        $client->update($request->validated());

        return redirect()->route('clients.index')->with('status', 'Client updated.');
    }

    public function destroy(Client $client): RedirectResponse
    {
        $client->update(['status' => $client->status === 'active' ? 'inactive' : 'active']);

        return redirect()->route('clients.index')->with('status', $client->status === 'active' ? 'Client activated.' : 'Client disabled.');
    }
}
