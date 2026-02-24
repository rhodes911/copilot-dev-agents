---
applyTo: "**"
---

# Agent System — Global Rules

## Development Lifecycle

This project uses a four-stage development lifecycle. Every piece of work must pass through all four stages.

| Stage | Agent | Output |
|-------|-------|--------|
| 1. Discovery | Discovery | `TICKET-STATUS.md` + investigation findings |
| 2. Planning | Planner | `DEV-PLAN-{NUMBER}.md` |
| 3. Build | Build | Code + passing tests |
| 4. Review | Review | Sign-off or `REVIEW-{NUMBER}.md` with numbered issues |

For development lifecycle work, always use the appropriate agent for the current stage.

---

## Evidence-Based Practices (Non-Negotiable)

**NEVER assume or guess. ALWAYS read the actual files.**

Before making any decision or taking any action:

1. **Have I actually discovered the facts?**
   - Did I READ the relevant source files or am I assuming their content?
   - Did I VERIFY the existing codebase structure before proposing changes?
   - Did I CHECK test output rather than inferring it?

2. **Am I sure these are the right values?**
   - Did I SEARCH the codebase for existing patterns before creating new ones?
   - Did I CONFIRM environment variable names against `.env.example`?
   - Did I VERIFY the schema or interface against the actual source?

3. **Can I cite evidence?**
   - Can I name the exact file path and field for this value?
   - Did I RUN a command to verify this behaviour?
   - Do I have tool output or logs to support this?

Verification checklist before proceeding with any task:
- [ ] I have READ the relevant source files (not assumed values)
- [ ] I have VERIFIED parameter names against actual files
- [ ] I have SEARCHED for existing patterns before creating new ones
- [ ] I can CITE specific files and lines for my decisions
- [ ] I have TESTED or verified runtime behaviour where applicable

---

## Epic & Ticket Structure

### File Layout

```
docs/epics/EPIC-{NUMBER}/
    EPIC-STATUS.md
docs/tickets/TICKET-{NUMBER}/
    TICKET-STATUS.md
    DEV-PLAN-{NUMBER}.md
```

### Epic Branch Policy (Non-Negotiable)

One branch per epic. Never work directly on `main`.

- Create: `git checkout main && git pull && git checkout -b epic/EPIC-{NUMBER}`
- Merge: PR `epic/EPIC-{NUMBER}` → `main` after Review Agent sign-off

---

## Required Discussion Section

Every agent must include a Discussion section in their primary deliverable:

```
## Discussion

### Acceptance Criteria
- AC1: ...

### Evidence
- AC1 evidence: Ran `...` --> result `...`

### Notes / Risks
- ...
```

---

## Documentation Policy

- User-facing documentation lives in `README.md`.
- Review Agent must update `README.md` before epic sign-off when any user-facing feature changes.
- `docs/` contains only `epics/`, `tickets/`, and `templates/`.
