# Agents

This repository provides **four VS Code custom agents** for the GitHub Copilot Chat Agent dropdown. Together they implement a structured, evidence-based development lifecycle.

---

## How To Use

1. Open **Copilot Chat** in VS Code
2. Click the **Agent** dropdown
3. Select the agent for the current workflow stage
4. For Discovery: describe your feature or requirement
5. For Planner, Build, Review: include the ticket number (e.g. `ticket=TICKET-00001`)

> Attach the active ticket folder (`docs/tickets/TICKET-XXXXX/`) to the chat context before invoking Planner, Build, or Review.

---

## The Four Agents

| Agent | Dropdown Name | Role |
|-------|--------------|------|
| Discovery | Discovery | Identify or create the parent epic; create the epic branch; scope the request; create the ticket; investigate constraints |
| Planner | Planner | Produce an architecture plan (module map, interfaces, acceptance criteria) — no code |
| Build | Build | Implement and test in one TDD pass; run tests before handoff |
| Review | Review | Code review + UAT evidence + final sign-off, or return to Build with a numbered issue list |

---

## Workflow

```
User Request
     ↓
[Discovery] → Identify / create Epic in docs/epics/ → EPIC-STATUS.md
     ↓
[Discovery] → Create epic branch: git checkout -b epic/EPIC-{NUMBER}
     ↓
[Discovery] → Scope + ticket + investigate → TICKET-STATUS.md
     ↓
[Planner]   → Architecture plan → DEV-PLAN-{NUMBER}.md
     ↓
[Build]     → Code + tests (TDD) → tests passing
     ↓
[Review]    → Code review + UAT + sign-off → ticket done (or back to Build)
     ↓ (final ticket in epic)
[Review]    → Verify epic-level AC → EPIC-STORY-{NUMBER}.md
     ↓
[Review]    → PR: epic/EPIC-{NUMBER} → main → merge
```

---

## Source Files

- Agent definitions: [.github/agents/](.github/agents/)
- Global instructions: [.github/copilot-instructions.md](.github/copilot-instructions.md)
- Scoped instructions: [.github/instructions/](.github/instructions/)
- Epics index: [docs/epics/INDEX.md](docs/epics/INDEX.md)
- Tickets index: [docs/tickets/INDEX.md](docs/tickets/INDEX.md)
- Templates: [docs/templates/](docs/templates/)
