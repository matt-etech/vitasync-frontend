# VitaSync Roadmap Status

Last Updated: 2026-04-14
Source of truth:
- `Requirements.md` (phase scope and exit criteria)
- `AGENTS.md` (engineering and quality rules)
- `DesignBrandGuide.md` (UI/UX and branding rules)

Update Rules:
- Update this file whenever phase status, blockers, or milestone targets change.
- Only move a phase to `DONE` when all phase exit criteria in `Requirements.md` are satisfied.
- Keep notes concise and factual; log blockers with owner and next action.

## Status Legend
- `NOT_STARTED`
- `IN_PROGRESS`
- `BLOCKED`
- `DONE`

## Overall Progress
- Current Phase: `0 - Platform Foundation`
- Overall Status: `IN_PROGRESS`

---

## Phase Tracker

### Phase 0 — Platform Foundation
- Status: `IN_PROGRESS`
- Exit Criteria Check:
  - [ ] Role/permission checks enforced on protected actions
  - [ ] Audit events emitted for create/update/delete and critical workflow actions
  - [ ] Notification events emitted from domain events
  - [ ] Documents can be stored, retrieved, and audited
  - [ ] Basic global search works on core entities
- Notes:
  - Project scaffolding complete (`backend`, `frontend`)
  - Laravel login, local Bootstrap/Font Awesome UI shell, users/roles/permissions CRUD, permission middleware, home CRUD, logo upload, and home-scoped user management are implemented.
  - Role/permission checks are enforced for the implemented identity and home-management protected routes; broader Phase 0 enforcement remains open for future modules.

### Phase 1 — Minimum Care Loop
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] End-to-end care loop completes
  - [ ] EVV check-in/check-out timestamps captured and linked to visits
  - [ ] Full audit trail exists for the loop

### Phase 2 — Safety & Compliance Core
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Risk, consent/capacity, medication, incident, safeguarding workflows operational
  - [ ] Medication administration recorded with accountability
  - [ ] Incident to safeguarding escalation traceable end-to-end

### Phase 3 — Workforce & Scheduling Intelligence
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Scheduler blocks non-compliant/unavailable staff assignments
  - [ ] Skills and availability constraints enforced
  - [ ] Late/missed visit detection alerts operational

### Phase 4 — EVV & Real-Time Monitoring
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] GPS/location-verified EVV evidence captured
  - [ ] Real-time status and escalation workflows functioning
  - [ ] Manager operational view reflects live visit state

### Phase 5 — Billing & Payroll Engine
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Billing generated from verified visit evidence and rate rules
  - [ ] Payroll generated from worked time and rule set
  - [ ] Multi-funder support validated

### Phase 6 — Governance & QA Engine
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Complaints, audits, GDPR workflows, and action tracking operational
  - [ ] Governance workflow provides traceable outcomes/evidence

### Phase 7 — Reporting & BI
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Reports/dashboards produce consistent, exportable, auditable data
  - [ ] Report outputs reconcile with operational source-of-truth data

### Phase 8 — Communication & Integration
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Internal/external messaging and APIs function with consent + audit controls
  - [ ] Backward-compatible integration contracts documented and testable

### Phase 9 — Supported Living Extensions
- Status: `NOT_STARTED`
- Exit Criteria Check:
  - [ ] Supported living modules operational with full auditability/safety controls
  - [ ] Extensions integrate without breaking core care workflows

---

## Blockers / Risks
- None logged yet.

## Next Milestone
- Complete Phase 0 foundation slice with auditable identity, permissions, audit eventing, documents, notifications, and basic search.
