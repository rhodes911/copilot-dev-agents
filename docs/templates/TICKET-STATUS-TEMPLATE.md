# TICKET-STATUS Template

<!-- Copy to docs/tickets/TICKET-{NUMBER}/TICKET-STATUS.md and fill in. -->

## Overview

| Field | Value |
|-------|-------|
| **Ticket** | TICKET-{NUMBER} |
| **Epic** | [EPIC-{N}](../../epics/EPIC-{N}/EPIC-STATUS.md) |
| **Title** | {Short title} |
| **Status** | pending / in-progress / review / done |
| **Created** | {YYYY-MM-DD} |

## Description

{What is being built and why — 2–4 sentences.}

## Workflow Progress

| Stage | Status | Agent | Date |
|-------|--------|-------|------|
| Discovery | ⏳ Pending | Discovery | — |
| Planning | ⏳ Pending | Planner | — |
| Build | ⏳ Pending | Build | — |
| Review | ⏳ Pending | Review | — |

## Investigation Findings (Discovery Agent)

### Interface / Schema Impact
{Exact fields added, changed, or removed — with file paths}

### Dependency Impact
{New libraries, APIs, or services required}

### Test Impact
{Files affected; simplest test that proves AC}

### Environment Variable Impact
{New vars required; confirmation they're added to .env.example}

### Risks / Constraints
{Anything that might block Build}

## Acceptance Criteria

- [ ] AC1: {Verifiable criterion}
- [ ] AC2: ...

## Build Notes

### Files Changed
{Build Agent populates: list of files changed and why}

### Test Run
```
{paste exact test output summary}
```

### Commands to Verify
```bash
{exact commands a reviewer can run to reproduce}
```

## Review

### Evidence
{Review Agent populates: test output, manual test steps, API examples (sanitised)}

### Outcome
- [ ] Approved — ticket closed
- [ ] Returned to Build — see REVIEW-{NUMBER}.md

## Discussion

### Acceptance Criteria
- AC1: ...

### Evidence
- AC1 evidence: Ran `...` → result `...`

### Notes / Risks
- ...
