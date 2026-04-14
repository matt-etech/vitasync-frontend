# VitaSync Design Guidelines & Branding System  
### For a Regulated Care Operating Platform

Last Updated: 2026-04-11
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

## 4.2 Status Indicators

Use consistent visual patterns:

- Color badge
- Icon + label

### Examples
- 🔴 Missed
- 🟠 Late
- 🟢 Completed

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

## Top Bar
- Search
- Alerts
- User profile

## Left Navigation
- Dashboard
- Care
- Workforce
- Scheduling
- Finance
- Governance
- Reports
- Integrations

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
