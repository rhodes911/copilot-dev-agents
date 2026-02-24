# DEV-PLAN Template

<!-- Copy to docs/tickets/TICKET-{NUMBER}/DEV-PLAN-{NUMBER}.md and fill in (Planner Agent). -->

# DEV-PLAN-{NUMBER} — {Ticket Title}

## Summary

{2–4 sentences: what is being built, why it is needed, and which epic it belongs to.}

## Affected Modules

| File | Change Type | Description |
|------|-------------|-------------|
| `src/example.ts` | Modify | {What the change is} |
| `tests/example.test.ts` | Create | {What is tested} |

## Interface / Schema Changes

{Exact additions or modifications to any public interface, config schema, or API contract.}
{If none: "No interface changes."}

## New Dependencies

{Package name, version range, why it's needed.}
{If none: "None."}

## Acceptance Criteria

- AC1: {Specific, independently verifiable statement}
- AC2: ...

## Test Plan

| AC | Test File | Approach |
|----|-----------|----------|
| AC1 | `tests/example.test.ts` | Unit — mock external calls; assert return shape |

## Risks

- {Risk description and mitigation strategy}
