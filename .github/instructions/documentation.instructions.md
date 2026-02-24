---
applyTo: "docs/**/*.md,README.md"
---

# Documentation Instructions

## Context

You are maintaining documentation for a project that uses the multi-agent development lifecycle system. Documentation must stay in sync with the current codebase, interfaces, and agent behaviour.

## Documentation Types

| Type | Location | Audience |
|------|----------|----------|
| Quick reference | `README.md` | Any user or contributor — first touchpoint |
| Developer tickets | `docs/tickets/` | Development agents, contributors |
| Epic tracking | `docs/epics/` | Development agents, project leads |

## When to Update

- **README.md**: Whenever setup steps, env vars, interfaces, or quick-start commands change
- **Ticket files**: Continuously — every agent phase updates TICKET-STATUS.md

## Style

- Use plain Markdown — no raw HTML
- Use tables for reference data, bullet lists for steps, code blocks for commands/JSON/output
- Keep README concise — link to further documentation for detail
- Use relative links between doc files

## Required Sections in README.md

```markdown
## Overview
## Quick Start
## Configuration
## Development Workflow
## Troubleshooting
```

## Interface / Schema Documentation Rule

When documenting an interface, config schema, or API contract, always include:
- The exact field or property name
- Type
- Example value
- Which module(s) consume it
- Validation rules (if any)

## Accuracy Rule

Never document a field, command, or behaviour that you have not verified by reading the actual source. If you are unsure, read the file first.
