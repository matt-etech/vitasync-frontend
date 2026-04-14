# VitaSync Modernisation — Incremental Development Blueprint

Last Updated: 2026-04-11
Related Documents:
- `AGENTS.md` (engineering and delivery rules)
- `DesignBrandGuide.md` (UI/UX and branding rules)
- `ROADMAP_STATUS.md` (phase progress tracker)

## Core Principle

**Build vertical workflows, not isolated features.**

Every increment must answer:

> Can this slice safely run real care operations and produce auditable evidence?

If not, it is incomplete.

---

# 0. Phase 0 — Platform Foundation (NON-NEGOTIABLE)

## Components
- Identity & Roles
- Permissions (role-based, extendable to field-level)
- Audit Trail (global)
- Document Store
- Notification Engine (event-driven)
- Global Search (basic)
- Core Entity Framework (IDs, timestamps, ownership)

## Expected Behaviour
- Every action is:
  - Attributable
  - Timestamped
  - Auditable
- All modules emit events → notifications

## Data Entities
- User
- Role
- Permission
- AuditEvent
- Document
- NotificationEvent

## Output
A secure, traceable system base for regulated data.

---

# 1. Phase 1 — Minimum Care Loop

## Goal
Enable **real care delivery flow**

## Components
- Client
- Assessment (basic)
- Care Plan (task-level)
- Visit Scheduling (basic)
- Visit Execution (care notes)
- Basic EVV (check-in/out timestamps)

## Workflow
1. Create client  
2. Record needs  
3. Create care plan  
4. Schedule visit  
5. Assign worker  
6. Execute visit  
7. Record notes  

## Data Entities
- Client
- Assessment
- CarePlan
- CareTask
- Visit
- VisitAssignment
- VisitNote
- EVVEvent

## Dependency
- Uses platform foundation

## Output
Minimal operational system

---

# 2. Phase 2 — Safety & Compliance Core

## Goal
Make system **clinically and legally safe**

## Components
- Risk Assessments
- Consent & MCA
- Medication (basic eMAR)
- Incident Logging
- Safeguarding (basic workflow)

## Behaviour
- Clients have risk + consent records
- Visits include medication administration
- Issues → incidents → safeguarding escalation

## Data Entities
- RiskAssessment
- ConsentRecord
- CapacityAssessment
- Medication
- MedicationAdministration
- Incident
- SafeguardingCase

## Dependency
- Extends care loop

## Output
Legally defensible care system

---

# 3. Phase 3 — Workforce & Scheduling Intelligence

## Goal
Make system **operationally safe**

## Components
- Staff Master Record
- Training & Compliance (DBS, certs)
- Availability & Leave
- Skill Matching
- Enhanced Scheduling
- Alerts (late/missed visits)

## Behaviour
- Cannot assign non-compliant staff
- Scheduling considers:
  - Skills
  - Availability
  - Location
- System detects failures (missed/late visits)

## Data Entities
- Worker
- TrainingRecord
- ComplianceCheck
- Availability
- Leave
- SkillTag
- ScheduleRule

## Dependency
- Scheduling depends on:
  - Client needs
  - Care plan tasks
  - Worker constraints

## Output
Operationally viable workforce system

---

# 4. Phase 4 — EVV & Real-Time Monitoring

## Goal
Make system **verifiable and trustworthy**

## Components
- GPS-based EVV
- Real-time tracking
- Escalation workflows
- Route optimisation (basic)

## Behaviour
- Visits are location-verified
- System flags:
  - Late visits
  - Missed visits
- Managers see live status

## Data Entities
- EVVEvent (enhanced)
- GeoLocation
- VisitStatus
- EscalationEvent

## Dependency
- Feeds:
  - Dashboard
  - Alerts
  - Future billing

## Output
Reliable operational evidence

---

# 5. Phase 5 — Billing & Payroll Engine

## Goal
Convert operations into **revenue and payroll**

## Components
- Billing Engine
- Funder Rules
- Invoice Generation
- Payroll Engine

## Behaviour
- Invoice = verified visits × rates
- Payroll = worked time × rules
- Supports multi-funder logic

## Data Entities
- Funder
- Contract
- RateCard
- Invoice
- PayrollRun
- Timesheet

## Dependency
- Requires:
  - EVV accuracy
  - Scheduling integrity
  - Worker data

## Output
Commercially functional system

---

# 6. Phase 6 — Governance & QA Engine

## Goal
Make system **regulator-ready**

## Components
- Complaints Management
- Audit Engine
- Policy Library
- GDPR Suite (SAR, DPIA, breaches)
- Governance Meetings
- Action Tracking

## Behaviour
- All issues generate:
  - Actions
  - Traceable outcomes
- System supports inspections

## Data Entities
- Complaint
- Audit
- Policy
- SARRequest
- Breach
- ActionPlan
- GovernanceMeeting

## Dependency
- Pulls from all modules

## Output
Full compliance layer

---

# 7. Phase 7 — Reporting & BI

## Goal
Enable **decision-making**

## Components
- Operational Reports
- Workforce Analytics
- Financial Reporting
- Inspection Dashboards
- Custom Report Builder

## Behaviour
- Managers see:
  - Risks
  - Trends
  - Performance
- Exportable data

## Dependency
- Entire system must be consistent

## Output
Intelligence layer

---

# 8. Phase 8 — Communication & Integration

## Goal
Connect system to **people and external systems**

## Components
- Internal Messaging
- Family Portal (consent-based)
- GP/Healthcare Messaging
- APIs
- NHS / LA Integrations

## Behaviour
- Families access permitted data
- External systems exchange data

## Dependency
- Requires:
  - Consent model
  - Security
  - Audit

## Output
Ecosystem integration

---

# 9. Phase 9 — Supported Living Extensions

## Goal
Support **additional care model**

## Components
- Tenancy Management
- PBS Plans
- Restrictive Practice Register
- 24/7 Shift Logs

## Behaviour
- Supports continuous care
- Tracks behavioural and housing needs

## Dependency
- Extends core system

## Output
Full care platform coverage

---

# Final Architecture Structure

## Backend (Laravel, MySQL in production)
- `Identity & Access`: users, roles, permissions, authorization policy engine
- `Audit & Evidence`: audit events, immutable action logs, document metadata
- `Care Delivery`: clients, assessments, care plans, visits, notes, EVV
- `Clinical Safety`: risks, consent/MCA, medications, incidents, safeguarding
- `Workforce`: worker records, compliance, skills, availability, scheduling rules
- `Operations & Monitoring`: live visit status, alerts, escalations, tracking
- `Finance`: funders, contracts, rates, invoices, payroll, timesheets
- `Governance`: complaints, audits, policies, SAR, breaches, actions
- `Reporting`: operational, workforce, financial, inspection datasets
- `Integration`: messaging, external APIs, interoperability connectors

## Frontend (Web + Flutter Mobile)
- Workflow-first modules mapped to phase progression
- State-aware task surfaces for carer, manager, and admin roles
- Shared design tokens and component patterns aligned to brand guide
- Offline-resilient interaction patterns for field workflows

## Cross-Cutting Layers
- Authentication and authorization
- Event bus and notification pipeline
- Global search
- Observability (logs, metrics, traceable correlation IDs)
- Data protection and records lifecycle controls

---

# Phase Exit Criteria (Mandatory)

## Phase 0 Exit
- Role/permission checks enforced on protected actions
- Audit events emitted for create/update/delete and critical workflow actions
- Notification events emitted from domain events
- Documents can be stored, retrieved, and audited
- Basic global search works on core entities

## Phase 1 Exit
- End-to-end care loop completes: client → assessment → care plan → schedule → assignment → visit execution → notes
- EVV check-in/check-out timestamps captured and linked to visits
- Full audit trail exists for the loop

## Phase 2 Exit
- Risk, consent/capacity, medication, incident, and safeguarding workflows operational
- Medication administration recorded in visits with accountability
- Incident to safeguarding escalation traceable end-to-end

## Phase 3 Exit
- Scheduling blocks assignment of non-compliant or unavailable staff
- Skills/availability constraints enforced by scheduler
- Late/missed visit detection alerts are operational

## Phase 4 Exit
- GPS/location-verified EVV evidence captured for active visits
- Real-time status and escalation workflows functioning
- Manager operational view reflects live visit state

## Phase 5 Exit
- Billing generated from verified visit evidence and rate rules
- Payroll generated from worked time and rule set
- Multi-funder rule support validated on representative scenarios

## Phase 6 Exit
- Complaints, audits, GDPR requests/breaches, and action tracking operational
- Governance workflow provides traceable outcomes and evidence

## Phase 7 Exit
- Core reports and dashboards produce consistent, exportable, auditable data
- Report results reconcile with operational source-of-truth records

## Phase 8 Exit
- Internal/external messaging and APIs function with consent and audit controls
- Backward-compatible integration contracts documented and testable

## Phase 9 Exit
- Supported living modules operate with full auditability and safety controls
- Extended workflows integrate without breaking core care workflows

---

# Non-Functional Requirements (Mandatory)

- Security and privacy first: least privilege, strict tenant/user scoping, secure defaults
- Performance: optimize hot paths, prevent N+1 queries, use indexes and pagination
- Reliability: graceful failure handling, idempotent critical commands, retry-safe integrations
- Observability: structured logs, error tracking, and traceable workflow identifiers
- Availability and continuity: backup/restore procedures and recovery drills defined
- Data durability: no silent data loss, explicit transaction and rollback boundaries

---

# Data Governance And Compliance Baseline

- Classify sensitive data and apply least-necessary access
- Encrypt sensitive data in transit and at rest where required
- Define retention and deletion policies for clinical, audit, and attachment records
- Preserve legal/audit evidence integrity (tamper-evident history for critical actions)
- Maintain subject-rights workflow support (SAR, correction, deletion where lawful)

---

# API And Versioning Strategy

- Prefer additive, backward-compatible API changes by default
- Version breaking API changes explicitly (for example `/api/v2/...`)
- Maintain compatibility windows for existing clients during migrations
- Publish contract changes with request/response examples and error semantics

---

# Testing Strategy By Phase

- Phase 0-2: prioritize domain correctness, authorization, audit emission, and safety logic tests
- Phase 3-5: add scheduling, EVV verification, billing/payroll calculation integration tests
- Phase 6-9: add governance, reporting consistency, and integration contract tests
- Backend: use SQLite for tests where supported; production targets MySQL
- Frontend: test workflow completion, safety prompts, and state/risk/action clarity

---

# Data Migration And Rollout Strategy

- Introduce schema changes with reversible, deterministic migrations
- Use compatibility layers for live clients during contract transitions
- Backfill critical historical records before enabling dependent workflows
- Gate rollout by phase-exit criteria, not by UI completeness
- Use feature flags for high-risk modules when incremental rollout is required

---

# Execution Order Summary

1. Foundation (must exist first)
2. Care Loop (client → care → visit → notes)
3. Safety (risk, consent, medication, incidents)
4. Workforce (staff + scheduling constraints)
5. EVV (verification layer)
6. Finance (billing + payroll)
7. Governance (compliance engine)
8. Reporting (intelligence)
9. Integration (external ecosystem)
10. Extensions (supported living)

---

# Critical Rule

**Do not build:**
- Dashboards before data integrity  
- Reporting before consistency  
- Integrations before structure  
- UI before workflows  

---

# Core System Flow (Golden Path)
---

This is not a feature roadmap.

This is a **system evolution path from unsafe prototype → regulated care operating platform**.
