@extends('layouts.app')

@section('breadcrumbs')
    <x-breadcrumbs :items="[
        ['label' => 'Workspace', 'url' => route('dashboard')],
        ['label' => 'Care'],
        ['label' => 'Clients', 'url' => route('clients.index')],
        ['label' => $client->fullName()],
    ]" />
@endsection

@section('content')
    @php
        $statusBadge = $client->status === 'active' ? 'text-bg-success' : 'text-bg-secondary';
        $onboardingBadge = [
            'onboarding' => 'text-bg-info',
            'pending' => 'text-bg-warning',
            'approved' => 'text-bg-success',
            'declined' => 'text-bg-danger',
        ][$client->onboarding_status] ?? 'text-bg-secondary';

        $assessmentBadgeClass = fn (string $status): string => [
            'onboarding' => 'text-bg-info',
            'pending' => 'text-bg-warning',
            'approved' => 'text-bg-success',
            'declined' => 'text-bg-danger',
        ][$status] ?? 'text-bg-secondary';

        $sectionRows = function (?object $section, array $fields): array {
            if ($section === null) {
                return [];
            }

            return collect($fields)
                ->map(fn (string $label, string $field): array => [$label, $section->{$field}])
                ->filter(fn (array $row): bool => filled($row[1]))
                ->all();
        };

        $assessmentSections = function ($assessment) use ($sectionRows): array {
            return [
                'master' => [
                    'label' => 'Master',
                    'rows' => [
                        ['Assessment date', $assessment->assessment_date?->format('Y-m-d')],
                        ['Assessor', $assessment->assessor_name],
                        ['Type', ucfirst($assessment->assessment_type)],
                        ['Risk', $assessment->overall_risk_level ? ucfirst($assessment->overall_risk_level) : null],
                        ['Submitted', $assessment->submitted_at?->format('Y-m-d H:i')],
                        ['Reviewed', $assessment->reviewed_at?->format('Y-m-d H:i')],
                        ['Summary', $assessment->overall_summary],
                        ['Recommendations', $assessment->recommendations],
                        ['Review notes', $assessment->review_notes],
                    ],
                ],
                'needs' => ['label' => 'Needs', 'rows' => $sectionRows($assessment->needs, ['physical_needs' => 'Physical needs', 'psychological_needs' => 'Psychological needs', 'social_needs' => 'Social needs', 'spiritual_needs' => 'Spiritual needs', 'environmental_needs' => 'Environmental needs', 'priority_needs' => 'Priority needs', 'notes' => 'Notes'])],
                'functional' => ['label' => 'Functional', 'rows' => $sectionRows($assessment->functional, ['mobility_status' => 'Mobility', 'bathing_ability' => 'Bathing', 'dressing_ability' => 'Dressing', 'eating_ability' => 'Eating', 'toileting_ability' => 'Toileting', 'transferring_ability' => 'Transferring', 'continence_status' => 'Continence', 'independence_level' => 'Independence', 'notes' => 'Notes'])],
                'medical' => ['label' => 'Medical', 'rows' => $sectionRows($assessment->medical, ['diagnoses' => 'Diagnoses', 'medical_conditions' => 'Conditions', 'medications' => 'Medications', 'allergies' => 'Allergies', 'vital_signs' => 'Vital signs', 'gp_details' => 'GP details', 'medication_support_needed' => 'Medication support needed', 'notes' => 'Notes'])],
                'capacity' => ['label' => 'Capacity', 'rows' => $sectionRows($assessment->mentalCapacity, ['decision_type' => 'Decision type', 'understands_information' => 'Understands information', 'retains_information' => 'Retains information', 'weighs_information' => 'Weighs information', 'communicates_decision' => 'Communicates decision', 'capacity_outcome' => 'Outcome', 'best_interest_decision' => 'Best-interest decision', 'imca_involved' => 'IMCA involved', 'dols_lps_status' => 'DoLS/LPS status', 'notes' => 'Notes'])],
                'risk' => ['label' => 'Risk', 'rows' => $sectionRows($assessment->risk, ['falls_risk' => 'Falls', 'pressure_ulcer_risk' => 'Pressure ulcer', 'manual_handling_risk' => 'Manual handling', 'environmental_risk' => 'Environmental', 'behaviour_risk' => 'Behaviour', 'safeguarding_risk' => 'Safeguarding', 'control_measures' => 'Control measures', 'notes' => 'Notes'])],
                'communication' => ['label' => 'Communication', 'rows' => $sectionRows($assessment->communication, ['preferred_language' => 'Preferred language', 'communication_method' => 'Method', 'hearing_impairment' => 'Hearing impairment', 'vision_impairment' => 'Vision impairment', 'speech_difficulty' => 'Speech difficulty', 'interpreter_required' => 'Interpreter required', 'communication_aids' => 'Aids', 'notes' => 'Notes'])],
                'equality' => ['label' => 'Equality', 'rows' => $sectionRows($assessment->equality, ['gender' => 'Gender', 'ethnicity' => 'Ethnicity', 'religion' => 'Religion', 'disability_status' => 'Disability', 'sexual_orientation' => 'Sexual orientation', 'cultural_needs' => 'Cultural needs', 'reasonable_adjustments' => 'Reasonable adjustments', 'notes' => 'Notes'])],
                'social' => ['label' => 'Social', 'rows' => $sectionRows($assessment->social, ['living_arrangements' => 'Living arrangements', 'family_support' => 'Family support', 'social_isolation_risk' => 'Isolation risk', 'community_engagement' => 'Community engagement', 'employment_status' => 'Employment status', 'financial_concerns' => 'Financial concerns', 'notes' => 'Notes'])],
                'environmental' => ['label' => 'Environmental', 'rows' => $sectionRows($assessment->environmental, ['home_condition' => 'Home condition', 'safety_hazards' => 'Safety hazards', 'accessibility' => 'Accessibility', 'equipment_needed' => 'Equipment needed', 'fire_risk' => 'Fire risk', 'cleanliness_level' => 'Cleanliness', 'notes' => 'Notes'])],
            ];
        };
    @endphp

    <x-page-header title="{{ $client->fullName() }}" description="View client details and assessment history retained for audit.">
        <x-slot:action>
            <div class="d-flex flex-wrap gap-2">
                <a class="btn btn-outline-secondary" href="{{ route('clients.index') }}"><i class="fa-solid fa-arrow-left me-1"></i>Clients</a>
                <a class="btn btn-primary" href="{{ route('clients.assessments.edit', $client) }}"><i class="fa-solid fa-list-check me-1"></i>New assessment version</a>
            </div>
        </x-slot:action>
    </x-page-header>

    <div class="card shadow-sm">
        <div class="card-body p-4">
            <ul class="nav nav-tabs" id="clientShowTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="client-details-tab" data-bs-toggle="tab" data-bs-target="#client-details-pane" type="button" role="tab" aria-controls="client-details-pane" aria-selected="true">Client details</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="client-assessments-tab" data-bs-toggle="tab" data-bs-target="#client-assessments-pane" type="button" role="tab" aria-controls="client-assessments-pane" aria-selected="false">Assessments</button>
                </li>
            </ul>

            <div class="tab-content pt-4" id="clientShowTabsContent">
                <div class="tab-pane fade show active" id="client-details-pane" role="tabpanel" aria-labelledby="client-details-tab" tabindex="0">
                    <div class="row g-4">
                        <div class="col-lg-4">
                            <div class="border rounded p-4 h-100">
                                <p class="section-kicker mb-2">Client</p>
                                <h2 class="h4 fw-bold mb-3">{{ $client->fullName() }}</h2>
                                <div class="d-flex flex-wrap gap-2">
                                    <span class="badge {{ $statusBadge }}">{{ ucfirst($client->status) }}</span>
                                    <span class="badge {{ $onboardingBadge }}">{{ ucfirst($client->onboarding_status ?: 'onboarding') }}</span>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-8">
                            <div class="border rounded p-4 h-100">
                                <dl class="row mb-0 g-3">
                                    <dt class="col-md-4 text-secondary">Home</dt>
                                    <dd class="col-md-8 mb-0">{{ $client->home->name }}</dd>
                                    <dt class="col-md-4 text-secondary">Date of birth</dt>
                                    <dd class="col-md-8 mb-0">{{ $client->date_of_birth?->format('Y-m-d') ?: 'Not recorded' }}</dd>
                                    <dt class="col-md-4 text-secondary">Gender</dt>
                                    <dd class="col-md-8 mb-0">{{ $client->gender ?: 'Not recorded' }}</dd>
                                    <dt class="col-md-4 text-secondary">Phone</dt>
                                    <dd class="col-md-8 mb-0">{{ $client->phone ?: 'Not recorded' }}</dd>
                                    <dt class="col-md-4 text-secondary">Email</dt>
                                    <dd class="col-md-8 mb-0">{{ $client->email ?: 'Not recorded' }}</dd>
                                    <dt class="col-md-4 text-secondary">Address</dt>
                                    <dd class="col-md-8 mb-0">{{ $client->address ?: 'Not recorded' }}</dd>
                                    <dt class="col-md-4 text-secondary">Emergency contact</dt>
                                    <dd class="col-md-8 mb-0">
                                        {{ $client->emergency_contact_name ?: 'Not recorded' }}
                                        @if ($client->emergency_contact_phone)
                                            <span class="d-block text-secondary">{{ $client->emergency_contact_phone }}</span>
                                        @endif
                                    </dd>
                                </dl>
                            </div>
                        </div>
                    </div>

                    @if ($client->review_notes)
                        <div class="alert alert-warning mt-4 mb-0">
                            <strong>Latest review notes:</strong> {{ $client->review_notes }}
                        </div>
                    @endif
                </div>

                <div class="tab-pane fade" id="client-assessments-pane" role="tabpanel" aria-labelledby="client-assessments-tab" tabindex="0" data-assessment-history>
                    <div class="d-flex flex-column flex-md-row gap-2 justify-content-md-between mb-3">
                        <div>
                            <p class="section-kicker mb-2">Assessment History</p>
                            <h2 class="h4 fw-bold mb-0">Assessment Versions</h2>
                        </div>
                        <span class="text-secondary fw-semibold">{{ $client->assessments->count() }} total versions</span>
                    </div>

                    @if ($client->assessments->isEmpty())
                        <div class="alert alert-info mb-0">No assessment versions have been created yet.</div>
                    @else
                        <div class="table-responsive mb-4">
                            <table class="table align-middle">
                                <thead>
                                    <tr>
                                        <th>Version</th>
                                        <th>Status</th>
                                        <th>Assessment date</th>
                                        <th>Submitted</th>
                                        <th>Reviewed</th>
                                        <th class="text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach ($client->assessments as $assessment)
                                        <tr>
                                            <td class="fw-bold">Version {{ $assessment->version }}</td>
                                            <td><span class="badge {{ $assessmentBadgeClass($assessment->status) }}">{{ ucfirst($assessment->status) }}</span></td>
                                            <td>{{ $assessment->assessment_date?->format('Y-m-d') ?: 'Not recorded' }}</td>
                                            <td>{{ $assessment->submitted_at?->format('Y-m-d H:i') ?: 'Not submitted' }}</td>
                                            <td>{{ $assessment->reviewed_at?->format('Y-m-d H:i') ?: 'Not reviewed' }}</td>
                                            <td class="text-end">
                                                <button class="btn btn-sm btn-action {{ $loop->first ? 'btn-action-primary' : '' }}" type="button" data-assessment-version-target="assessment-version-{{ $assessment->id }}">
                                                    <i class="fa-solid fa-eye"></i>Show
                                                </button>
                                            </td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>

                        @foreach ($client->assessments as $assessment)
                            @php($sections = $assessmentSections($assessment))
                            <section class="assessment-version-panel {{ $loop->first ? '' : 'd-none' }}" id="assessment-version-{{ $assessment->id }}">
                                <div class="border rounded p-3 p-md-4">
                                    <div class="d-flex flex-column flex-md-row gap-2 justify-content-md-between mb-3">
                                        <div>
                                            <h3 class="h5 fw-bold mb-1">Version {{ $assessment->version }}</h3>
                                            <p class="text-secondary mb-0">{{ $assessment->assessment_date?->format('Y-m-d') ?: 'No assessment date' }}</p>
                                        </div>
                                        <span class="badge {{ $assessmentBadgeClass($assessment->status) }} align-self-start">{{ ucfirst($assessment->status) }}</span>
                                    </div>

                                    <ul class="nav nav-tabs flex-nowrap overflow-auto" id="assessmentStepTabs{{ $assessment->id }}" role="tablist">
                                        @foreach ($sections as $key => $section)
                                            <li class="nav-item" role="presentation">
                                                <button class="nav-link {{ $loop->first ? 'active' : '' }}" id="assessment-{{ $assessment->id }}-{{ $key }}-tab" data-bs-toggle="tab" data-bs-target="#assessment-{{ $assessment->id }}-{{ $key }}-pane" type="button" role="tab" aria-controls="assessment-{{ $assessment->id }}-{{ $key }}-pane" aria-selected="{{ $loop->first ? 'true' : 'false' }}">
                                                    {{ $section['label'] }}
                                                </button>
                                            </li>
                                        @endforeach
                                    </ul>

                                    <div class="tab-content pt-4" id="assessmentStepTabsContent{{ $assessment->id }}">
                                        @foreach ($sections as $key => $section)
                                            <div class="tab-pane fade {{ $loop->first ? 'show active' : '' }}" id="assessment-{{ $assessment->id }}-{{ $key }}-pane" role="tabpanel" aria-labelledby="assessment-{{ $assessment->id }}-{{ $key }}-tab" tabindex="0">
                                                @php($rows = collect($section['rows'])->filter(fn (array $row): bool => filled($row[1]))->all())
                                                @if ($rows === [])
                                                    <p class="text-secondary mb-0">No details recorded for this step.</p>
                                                @else
                                                    <dl class="row g-3 mb-0">
                                                        @foreach ($rows as [$label, $value])
                                                            <dt class="col-md-4 text-secondary">{{ $label }}</dt>
                                                            <dd class="col-md-8 mb-0">{{ is_bool($value) ? ($value ? 'Yes' : 'No') : $value }}</dd>
                                                        @endforeach
                                                    </dl>
                                                @endif
                                            </div>
                                        @endforeach
                                    </div>
                                </div>
                            </section>
                        @endforeach
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
