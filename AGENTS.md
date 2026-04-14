# VitaSync Agent Guide

Last Updated: 2026-04-11

## Requirements Source Of Truth

- Always read and follow [Requirements.md](/Users/encrypter/Documents/DynamicWow/vitasync.stepanite.com/Requirements.md) before starting work.
- Re-check `Requirements.md` during implementation to keep phase order, workflow integrity, and delivery priorities aligned.
- If any task conflicts with `Requirements.md`, treat `Requirements.md` as the primary guidance and call out the conflict explicitly.

## Branding Source Of Truth

- Always read and follow [DesignBrandGuide.md](/Users/encrypter/Documents/DynamicWow/vitasync.stepanite.com/DesignBrandGuide.md) for UI/UX and visual decisions.
- This is mandatory for both web app and Flutter mobile app design work.
- Re-check `DesignBrandGuide.md` before implementing new screens/components and before finalizing UI changes.
- If a design choice conflicts with safety, compliance, or workflow clarity, prioritize safety-critical behavior and document the tradeoff.

## Roadmap Tracking Source Of Truth

- Always update [ROADMAP_STATUS.md](/Users/encrypter/Documents/DynamicWow/vitasync.stepanite.com/ROADMAP_STATUS.md) when phase status, blockers, or milestone state changes.
- Do not mark a phase `DONE` unless its exit criteria in `Requirements.md` are satisfied.

## Documentation Naming Conventions (Mandatory)

- Use `UPPER_SNAKE_CASE.md` for process/governance docs (example: `ROADMAP_STATUS.md`, `ARCHITECTURE_DECISIONS.md`).
- Use `PascalCase.md` only for established product reference docs already in use (example: `Requirements.md`, `DesignBrandGuide.md`).
- Keep file names short, explicit, and domain-specific; avoid generic names like `notes.md` or `temp.md`.
- One responsibility per document: avoid mixing roadmap, standards, and branding concerns in one file.
- When introducing a new source-of-truth document, link it from `AGENTS.md`.

## Engineering Standard (Mandatory)

All work in this repository must enforce SOLID principles and long-term maintainability.
This is mandatory for both:
- Backend (`/backend`, Laravel/PHP)
- Frontend (`/frontend`, Flutter/Dart)

### SOLID Enforcement

- **Single Responsibility Principle (SRP):** each class, service, and widget must have one clear responsibility.
- **Open/Closed Principle (OCP):** design modules for extension without modifying stable core behavior.
- **Liskov Substitution Principle (LSP):** abstractions must be safely replaceable without behavioral surprises.
- **Interface Segregation Principle (ISP):** prefer small, focused interfaces over broad contracts.
- **Dependency Inversion Principle (DIP):** depend on abstractions; use dependency injection for infrastructure and external services.

### Maintainability Rules

- Keep controllers/routes/UI thin; place business logic in domain services or use cases.
- Separate transport, business rules, persistence, and presentation concerns.
- Use explicit contracts (DTOs/value objects) at boundaries.
- Validate input at trust boundaries and fail with clear, actionable errors.
- Keep diffs narrow, coherent, and easy to review.
- Prefer composition over inheritance unless an existing pattern requires inheritance.
- Avoid premature abstraction, but remove duplication when it becomes structural.
- Preserve backward-compatible contracts unless a task explicitly requires breaking changes.
- Emit audit and domain events for critical state changes.
- Add focused tests for critical workflows and regression-prone logic.

### Database Design And Performance (Mandatory)

- Use MySQL for production workloads.
- Use SQLite for automated tests where the test suite supports it.
- Design schemas for correctness first: clear keys, constraints, nullability, and referential integrity.
- Add and maintain proper indexes for hot filters, joins, ordering, and unique constraints.
- Avoid N+1 query patterns; use eager loading and targeted query shaping.
- Select only required columns; avoid oversized payloads and unbounded scans.
- Keep transactions minimal and explicit; ensure safe rollback behavior on failure.
- Use pagination/chunking for large result sets.
- Review and optimize slow queries with query plans before shipping performance-sensitive changes.
- Keep migrations reversible, deterministic, and safe for existing data.

### Validation And Quality Gates (Mandatory)

- Backend changes: run `php -l` on changed PHP files and run relevant backend tests before marking work complete.
- Frontend changes: run `flutter analyze` and relevant frontend tests before marking work complete.
- If a required check cannot run, state exactly what failed and why, and do not imply verification passed.

### Commit Discipline

- Commit code changes when necessary and strategically in coherent, reviewable units.
- Use clear commit messages that describe intent and scope.
- Avoid mixing unrelated changes in the same commit.

### UX/UI Design Principles (Mandatory)

- Apply Domain-Driven UX (DDUX): design around real care workflows, not isolated screens.
- Prioritize workflow outcomes (for example, completing a care delivery flow) over page-centric design.
- Apply safety-critical UX principles: prevent errors proactively, not just display information.
- Use Workflow-First UX: each screen must clearly support the immediate user decision or action.
- Use State-Aware UI: always make visible the current state, risk level, and required next action.
- Favor clarity, speed, and safe task completion over visual complexity.

### Clinical UX Quality Gates (Mandatory)

- Accessibility: meet WCAG 2.2 AA standards, including keyboard navigation, screen-reader compatibility, and sufficient color contrast.
- Human factors: reduce cognitive load, use progressive disclosure, and require explicit confirmations for high-risk actions.
- Clinical safety governance: maintain a UX hazard log with severity, mitigation, and verification status for safety-critical flows.
- Measurable UX quality: track and review task success rate, time-to-complete, user error rate, and missed-alert rate.
- Design consistency: use shared design tokens and reusable components to prevent unsafe UI inconsistency.

### Delivery Requirement

A task is complete only when:

1. The requested behavior works end-to-end.
2. The implementation follows SOLID and repository architecture boundaries.
3. Relevant checks/tests were run (or clearly documented if not possible).
4. The result is understandable and maintainable by another engineer.
