# GitHub Copilot Instructions — Multi-Agent Development Lifecycle System

## System Overview

This repository provides a **reusable VS Code multi-agent development lifecycle system** using GitHub Copilot Agent Mode. It gives every project a structured, evidence-based workflow from raw requirement through to reviewed, merged code.

The four development lifecycle agents are:

| Agent | Role |
|-------|------|
| **Discovery** | Scope the request, create the epic/ticket, investigate constraints |
| **Planner** | Produce a detailed architecture plan — no code |
| **Build** | Implement + test in one TDD pass |
| **Review** | Code review, UAT evidence, sign-off or return to Build |

---

## Evidence-Based Development Principles

**ALL agents MUST work with data-driven, evidence-based practices. NEVER assume or guess.**

### Self-Critique Requirements

Before making ANY decision or taking ANY action, ask yourself:

1. **Have I actually discovered the facts here?**
   - Did I READ the relevant source files or am I assuming their content?
   - Did I VERIFY the existing codebase structure before proposing changes?
   - Did I CHECK test output rather than inferring it?

2. **Am I sure these are the right parameters?**
   - Did I SEARCH the codebase for existing patterns before creating new ones?
   - Did I CONFIRM environment variable names against `.env.example`?
   - Did I VERIFY the schema or interface against the actual source?

3. **Am I guessing or do I have evidence?**
   - Can I cite the file path and line for this value?
   - Did I RUN a command to verify this behaviour?
   - Do I have tool output or logs to support this?

### Verification Checklist (All Agents)

Before proceeding with any task:
- [ ] I have READ the relevant source files (not assumed values)
- [ ] I have VERIFIED parameter names against actual files
- [ ] I have SEARCHED for existing patterns before creating new ones
- [ ] I can CITE specific files/lines for my decisions
- [ ] I have TESTED or verified runtime behaviour where applicable

---

## Epic & Ticket Structure

### File Layout

```
docs/epics/EPIC-{NUMBER}/
└── EPIC-STATUS.md
docs/tickets/TICKET-{NUMBER}/
├── TICKET-STATUS.md
└── DEV-PLAN-{NUMBER}.md
```

### Epic Branch Policy (Non-Negotiable)

One branch per epic. Never work directly on `main`.

| Action | Command |
|--------|---------|
| Create epic branch | `git checkout main && git pull && git checkout -b epic/EPIC-{NUMBER}` |
| Merge when done | PR `epic/EPIC-{NUMBER}` → `main` after Review Agent sign-off |

---

## Ticket Workflow Stages

| Stage | Agent | Output |
|-------|-------|--------|
| 1. Discovery | Discovery | `TICKET-STATUS.md` + investigation findings |
| 2. Planning | Planner | `DEV-PLAN-{NUMBER}.md` |
| 3. Build | Build | Code + passing tests |
| 4. Review | Review | Sign-off or `REVIEW-{NUMBER}.md` with numbered issues |

---

## Required "Discussion" Section (Acceptance Criteria Evidence)

Every agent must include a **Discussion** section in their primary deliverable:

```markdown
## Discussion

### Acceptance Criteria
- AC1: ...

### Evidence
- AC1 evidence: Ran `...` → result `...`

### Notes / Risks
- ...
```

---

## Documentation Policy

- User-facing documentation lives in `README.md` (quick reference).
- Review Agent must update `README.md` before epic sign-off when any user-facing feature changes.
- `docs/` contains only `epics/`, `tickets/`, and `templates/`.
