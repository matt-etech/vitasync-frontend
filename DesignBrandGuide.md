# VitaSync Design Guidelines & Branding System  
### For a Regulated Care Operating Platform

Last Updated: 2026-04-14
Related Documents:
- `Requirements.md` (phase workflow priorities)
- `AGENTS.md` (engineering and validation rules)
- `ROADMAP_STATUS.md` (delivery progress tracker)

---

# 1. Core Design Philosophy (Non-Negotiable)

The UI is not decoration. It is a **safety-critical interface**.

## Priority Order
1. Safety  
2. Compliance  
3. Clarity under pressure  
4. Efficiency  
5. Aesthetics (last)

## Principles
- Never hide risk
- Always show system state
- Design for tired, interrupted users
- Every action must be traceable

---

# 2. Brand Positioning

## What the product should feel like:
> Clinical-grade operational control system

## NOT:
- Trendy startup UI
- Flashy SaaS dashboard
- Over-designed health app

## INSTEAD:
- Calm
- Structured
- Reliable
- Professional
- Trustworthy

---

# 3. Visual Identity System

## 3.1 Color System

### Primary Colors
- Deep Blue / Teal → trust, stability

### Neutral Base
- Off-white / light grey → reduce fatigue

### Semantic Colors (Strict Usage)

| Purpose        | Color  | Usage                          |
|----------------|--------|--------------------------------|
| Safe           | Green  | completed, compliant           |
| Warning        | Amber  | due soon, at risk              |
| Critical       | Red    | errors, missed visits          |
| Info           | Blue   | neutral information            |

### Rules
- Color = meaning (not decoration)
- Never use red for styling
- Use contrast for readability
- Do not allow default Bootstrap blue interaction states on navigation, tabs, or workflow controls. Use VitaSync teal and neutral states.

---

## 3.2 Typography

### Fonts
- Primary: Inter / Roboto
- Fallback: system fonts

### Requirements
- Highly readable
- Works on mobile + low-end devices

### Hierarchy
- Large headings → structure
- Medium text → labels
- Small text → metadata

### Rule
> Must be readable under stress

---

## 3.3 Spacing & Layout

### Principles
- Use generous spacing
- Group related items clearly
- Avoid dense layouts

### Grid
- 8px spacing system

### Shape
- Buttons, form controls, tabs, and dropdown items use small radii only: 8px maximum.
- Large structural shells may use softer rounding when it improves grouping, but action controls must remain nearly square.
- Avoid pill buttons unless a control is explicitly a status chip or compact filter.

---

## 3.4 Iconography

### Style
- Simple
- Line-based
- Recognizable

### Use
- Actions (edit, add)
- Status indicators

### Avoid
- Decorative icons
- Ambiguous visuals

---

# 4. Core UI Components

## 4.1 Work Card (Core Pattern)

Everything is task-driven.

### Example: Visit Card
- Client name
- Time
- Risk indicators
- Tasks
- Status
- Actions:
  - Start
  - Complete
  - Escalate

---

## 4.1.1 Action Buttons

Use VitaSync action button classes for table row actions and compact workflow actions instead of raw Bootstrap outline buttons.

### Shape And Density
- Buttons keep an 8px maximum radius.
- Table action buttons are compact but must keep readable labels.
- Use icon + label for row actions. Do not use icon-only destructive actions.

### Variants
- Primary page actions use the VitaSync teal primary button.
- Row view/manage actions use the calm teal-tinted action style.
- Row edit actions use neutral white with visible borders and dark text.
- Destructive actions use a red-tinted background with red text and border; never use solid red unless confirming a critical destructive action.

### Contrast
- Button text must be high contrast in normal, hover, and focus states.
- Borders must remain visible against white table backgrounds.
- Hover states may lift slightly, but must not shift layout.

---

## 4.2 Status Indicators

Use consistent visual patterns:

- Color badge
- Icon + label

### Examples
- 🔴 Missed
- 🟠 Late
- 🟢 Completed

---

## 4.2.1 Tabs

Tabs must use the VitaSync tab treatment, not raw Bootstrap defaults.

### Rules
- Active tabs use teal text with a teal top indicator.
- Inactive tabs use neutral text.
- Hover and focus states use a pale teal background with visible borders.
- Tabs keep an 8px maximum radius on the top corners.
- Horizontal tab lists may scroll on small screens but labels must remain readable.
- Do not use blue tab text or blue active states.

---

## 4.3 Timeline Component

Used for:
- Client history
- Visits
- Medication
- Incidents
- Notes

### Purpose
Chronological clarity

---

## 4.4 Alert Banner

### Types
- Warning
- Critical
- Informational

### Rules
- Never hide alerts
- Place near relevant action

---

## 4.5 Forms

### Rules
- Break into sections
- Inline validation
- Autosave enabled
- Avoid long scrolling forms
- Management create and edit actions must open in Bootstrap modals from the index page unless the workflow is a long clinical process, such as client onboarding assessments.
- Use the shared sectioned form shell for create/edit screens.
- Keep forms spacious on wide screens, but group fields into readable sections so related controls stay visually connected.
- Each major section must have a clear title and short guidance text.
- Put final submit/cancel controls in a visually distinct footer action bar.
- Use choice cards for checkbox groups such as roles and permissions.
- Role assignment should appear before direct permission assignment.
- Direct permissions must be framed as exceptions, not the default access model.
- Keep labels visible above fields and keep help text close to the field it explains.
- Preserve high contrast for labels, helper text, borders, and invalid states.
- Modal forms must use clear titles, scrollable bodies for long forms, and a visible cancel control.
- Do not use browser confirmation prompts. All confirmations must use the local SweetAlert2 asset and the shared confirmation pattern.
- Destructive-looking actions in management screens should be disable/activate actions, not hard delete actions.
- Disabled records may remain visible only on the management page where they can be activated or deactivated.
- Disabled records must not appear in unrelated assignment lists, dropdowns, navigation, or operational workflows.
- Activate/deactivate actions must require explicit SweetAlert confirmation and explain the effect of the state change.

### Client Onboarding Forms
- Client onboarding forms must start with client identity details, then contact/address, emergency contact, and home assignment.
- Required fields must be limited to details needed to safely create the record.
- Emergency contact fields should remain visible during onboarding because they support escalation.
- Status must be explicit and visible; default to active only when creating a real active client record.
- Client onboarding assessment must use a stepped workflow with a visible step list and breadcrumbs.
- Stepped assessment workflows must show progress as "current step of total steps" and a visible progress bar.
- Only the current assessment step should be shown; users move with Previous/Next controls or the step list.
- Assessment steps must include a master assessment record plus needs, functional, medical, mental capacity, risk, communication, equality, social, and environmental sections.
- Each assessment section must group evidence fields under clear clinical headings and keep notes close to the related evidence.
- Onboarding state must always be visible: onboarding, pending, approved, or declined.
- Submission must move the record to pending review; approval/decline must be explicit actions.
- Declines must capture review notes that tell the user what needs review before resubmission.
- Editing a submitted, declined, or approved assessment must create a new assessment version. Do not overwrite completed assessment evidence.
- Client detail pages must show submitted assessment history by version so review and adjudication decisions remain auditable.

---

## 4.6 Management Tables

Administrative and operational index tables must use the local DataTables asset bundle when the records are useful for review or reporting.

### Required Table Capabilities
- Search across visible table content.
- Pagination with a default page size of 10.
- Export controls for:
  - Copy
  - CSV
  - Excel
  - PDF
- Exclude action/control columns from exports.
- Keep table controls visually consistent with VitaSync controls: 8px maximum radius and calm neutral styling.
- Keep table controls high contrast: dark text on white controls, visible borders, and teal only for active/focus states.

### Rules
- Do not rely on remote CDN assets at runtime.
- Use server-rendered table content first, then progressively enhance with DataTables.
- Use server-side pagination only when datasets become too large for safe client-side rendering.
- Exported filenames/titles must describe the entity being exported.
- Export button text must always be visible; never rely on color-only or icon-only controls.
- Headers must have clear contrast against the table body and must remain readable when sorted.
- Disabled, empty, and filtered states must remain legible under WCAG 2.2 AA contrast expectations.
- Do not render manual empty-state rows with `colspan` inside DataTables tables. Let DataTables render the empty table state to avoid column-count errors.
- Table controls, table body, and footer pagination need clear spacing. The record count and pagination footer must not sit against the outer card edge.

### PDF Export Styling
- PDF exports must not use the default cramped DataTables layout.
- Use landscape A4 by default for management tables.
- Use clear page margins, a visible report title, generated timestamp, high-contrast table headers, readable row spacing, and page numbers.
- Stretch exported tables to the available page width where practical.
- Keep exported table colors aligned to VitaSync teal and neutral colors.

---

# 5. Interaction Design Rules

## 5.1 One Primary Action per Screen

Example:
- "Start Visit"
- "Record Medication"

---

## 5.2 Confirm Critical Actions

Required for:
- Medication submission
- Incident closure
- Deletions

---

## 5.3 Autosave Everything

Users will be interrupted.

---

## 5.4 Reduce Typing

Use:
- Dropdowns
- Templates
- Quick actions

---

## 5.5 Prevent Errors

- Disable invalid actions
- Guide users before failure

---

# 6. Role-Based UX

## Carer Interface
- Mobile-first
- Task-focused
- Minimal input
- Offline-ready mindset

## Manager Interface
- Dashboards
- Alerts
- Team overview
- Compliance tracking

## Admin Interface
- Configuration
- Governance
- Reporting

---

# 7. Application Layout Structure

## Workspace Header
- Use a two-level header for the web administration shell.
- Level 1: brand/home identity on the left; user identity, current home context, and logout on the right.
- Level 2: primary navigation below the header content.
- Header shell should feel calm and contained, with enough spacing to reduce cognitive load.

## Primary Navigation
- Use horizontal navigation for desktop management workflows.
- Group related links into clearly labelled dropdowns.
- Put `Users`, `Roles`, and `Permissions` under `User Management`.
- Use active states to show the current workspace.
- Show only navigation items the user has permission to access.

## Navigation Scope
- Only show modules that are implemented and permission-accessible.
- Do not add placeholder navigation for future phases.
- Future modules may be added when their workflows exist end-to-end.

## Main Area
- Tasks / data / workflow

## Right Panel (Optional)
- Context info (client, alerts)

---

# 8. Branding Voice & Language

## Tone
- Clear
- Direct
- Professional
- Human

## Avoid
- Vague language
- Over-friendly fluff
- Technical jargon

### Example

Bad:
> "Oops! Something went wrong"

Good:
> "Medication not recorded. Please confirm administration."

---

# 9. Accessibility (Mandatory)

- High contrast colors
- Large touch targets
- Keyboard navigation
- Screen reader compatibility

---

# 10. UI Deployment Strategy

## DO
- Release UI alongside backend phases
- Test with real users early
- Iterate based on real workflows

## DO NOT
- Design entire system upfront
- Focus on aesthetics first
- Copy generic SaaS dashboards

---

# 11. Design System Summary

Your UI must be:

- Calm → reduces stress  
- Structured → improves clarity  
- Action-driven → enables work  
- Safe → prevents errors  
- Trustworthy → builds confidence  

---

# 12. Anti-Patterns to Avoid

- Form-heavy UI
- Deep navigation layers
- Hidden alerts
- Overloaded dashboards
- Generic design without domain logic

---

# 13. Critical UX Test

Before building any screen, ask:

> Can a tired carer use this safely at 10pm without confusion?

If not → redesign

---

# 14. Priority Screens to Design First

1. Visit Execution Screen  
2. Medication Recording Screen  
3. Risk-Based Dashboard  

If these fail → the system fails

---

# 15. Final Insight

This is not a typical product UI.

It is:
> A real-time care execution and compliance system

Design accordingly.
