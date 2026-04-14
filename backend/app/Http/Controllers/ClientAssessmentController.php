<?php

namespace App\Http\Controllers;

use App\Http\Requests\ReviewClientAssessmentRequest;
use App\Http\Requests\UpdateClientAssessmentRequest;
use App\Models\Client;
use App\Models\ClientAssessment;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class ClientAssessmentController extends Controller
{
    public function edit(Client $client): View
    {
        $assessment = $this->assessmentFor($client)->load($this->sectionRelations());

        return view('clients.assessments.edit', [
            'client' => $client->load('home'),
            'assessment' => $assessment,
        ]);
    }

    public function update(UpdateClientAssessmentRequest $request, Client $client): RedirectResponse
    {
        DB::transaction(function () use ($request, $client): void {
            $assessment = $this->assessmentFor($client);
            $validated = $request->validated();

            $assessment->update(array_merge(data_get($validated, 'assessment', []), [
                'status' => ClientAssessment::STATUS_ONBOARDING,
                'submitted_at' => null,
                'reviewed_at' => null,
                'reviewed_by' => null,
                'review_notes' => null,
            ]));

            $this->syncSection($assessment, 'needs', data_get($validated, 'needs', []));
            $this->syncSection($assessment, 'functional', data_get($validated, 'functional', []));
            $this->syncSection($assessment, 'medical', data_get($validated, 'medical', []));
            $this->syncSection($assessment, 'mentalCapacity', data_get($validated, 'mental_capacity', []));
            $this->syncSection($assessment, 'risk', data_get($validated, 'risk', []));
            $this->syncSection($assessment, 'communication', data_get($validated, 'communication', []));
            $this->syncSection($assessment, 'equality', data_get($validated, 'equality', []));
            $this->syncSection($assessment, 'social', data_get($validated, 'social', []));
            $this->syncSection($assessment, 'environmental', data_get($validated, 'environmental', []));

            $client->update([
                'onboarding_status' => Client::ONBOARDING_STATUS_ONBOARDING,
                'submitted_at' => null,
                'reviewed_at' => null,
                'reviewed_by' => null,
                'review_notes' => null,
            ]);
        });

        return redirect()->route('clients.assessments.edit', $client)->with('status', 'Client assessment saved.');
    }

    public function submit(Client $client): RedirectResponse
    {
        DB::transaction(function () use ($client): void {
            $assessment = $this->assessmentFor($client);

            $assessment->update([
                'status' => ClientAssessment::STATUS_PENDING,
                'submitted_at' => now(),
                'reviewed_at' => null,
                'reviewed_by' => null,
                'review_notes' => null,
            ]);

            $client->update([
                'onboarding_status' => Client::ONBOARDING_STATUS_PENDING,
                'submitted_at' => now(),
                'reviewed_at' => null,
                'reviewed_by' => null,
                'review_notes' => null,
            ]);
        });

        return redirect()->route('clients.assessments.edit', $client)->with('status', 'Client onboarding submitted for review.');
    }

    public function approve(Client $client): RedirectResponse
    {
        DB::transaction(function () use ($client): void {
            $assessment = $this->assessmentFor($client);

            $assessment->update([
                'status' => ClientAssessment::STATUS_APPROVED,
                'reviewed_at' => now(),
                'reviewed_by' => auth()->id(),
                'review_notes' => null,
            ]);

            $client->update([
                'onboarding_status' => Client::ONBOARDING_STATUS_APPROVED,
                'reviewed_at' => now(),
                'reviewed_by' => auth()->id(),
                'review_notes' => null,
            ]);
        });

        return redirect()->route('clients.index')->with('status', 'Client onboarding approved.');
    }

    public function decline(ReviewClientAssessmentRequest $request, Client $client): RedirectResponse
    {
        DB::transaction(function () use ($request, $client): void {
            $assessment = $this->assessmentFor($client);
            $notes = $request->validated('review_notes');

            $assessment->update([
                'status' => ClientAssessment::STATUS_DECLINED,
                'reviewed_at' => now(),
                'reviewed_by' => auth()->id(),
                'review_notes' => $notes,
            ]);

            $client->update([
                'onboarding_status' => Client::ONBOARDING_STATUS_DECLINED,
                'reviewed_at' => now(),
                'reviewed_by' => auth()->id(),
                'review_notes' => $notes,
            ]);
        });

        return redirect()->route('clients.assessments.edit', $client)->with('status', 'Client onboarding declined with review notes.');
    }

    private function assessmentFor(Client $client): ClientAssessment
    {
        return $client->assessment()->firstOrCreate([], [
            'assessment_date' => now()->toDateString(),
            'assessment_type' => 'initial',
            'status' => ClientAssessment::STATUS_ONBOARDING,
        ]);
    }

    /**
     * @param array<string, mixed> $data
     */
    private function syncSection(ClientAssessment $assessment, string $relation, array $data): void
    {
        $assessment->{$relation}()->updateOrCreate([], $data);
    }

    /**
     * @return list<string>
     */
    private function sectionRelations(): array
    {
        return [
            'needs',
            'functional',
            'medical',
            'mentalCapacity',
            'risk',
            'communication',
            'equality',
            'social',
            'environmental',
        ];
    }
}
