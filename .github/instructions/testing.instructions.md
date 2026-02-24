---
applyTo: "tests/**,**/*.test.*,**/*.spec.*"
---

# Testing Instructions

## Philosophy

- **Test First (TDD)**: Write tests before implementing; let failing tests drive the implementation
- **Isolation**: Unit tests test one unit in isolation — mock all external dependencies (network, filesystem, time)
- **Determinism**: Tests must produce the same result every run — no timing dependencies, no shared state, no random values unless seeded
- **Coverage by AC**: Every acceptance criterion must have at least one test; do not write tests that do not map to an AC

## Test Structure

Follow the Arrange / Act / Assert pattern:

```typescript
// tests/unit/foo.test.ts
import { doThing } from "../../src/foo";

jest.mock("../../src/external-client"); // mock all external calls

describe("doThing", () => {
  beforeEach(() => jest.clearAllMocks());

  it("returns expected result when input is valid", async () => {
    // Arrange
    const input = { key: "value" };

    // Act
    const result = await doThing(input);

    // Assert
    expect(result.success).toBe(true);
    expect(result.data).toMatchObject({ key: "value" });
  });

  it("returns structured error when dependency fails", async () => {
    // Arrange
    const { externalClient } = require("../../src/external-client");
    (externalClient.call as jest.Mock).mockRejectedValue(new Error("Service unavailable"));

    // Act
    const result = await doThing({ key: "value" });

    // Assert
    expect(result.error).toBeDefined();
    expect(result.error).toContain("Service unavailable");
  });
});
```

## Naming Conventions

| Item | Convention |
|------|------------|
| Test files | Co-located with source as `*.test.ts` or in `tests/` mirroring `src/` |
| Describe blocks | Named after the module or function under test |
| It blocks | Plain English: `"returns X when Y"` or `"throws when Z"` |
| Fixture files | `tests/fixtures/` — one file per data shape |

## What Must Always Be Mocked

- HTTP/network calls
- Database queries
- Filesystem reads/writes (unless testing actual file I/O)
- Timers and dates (`jest.useFakeTimers()`)
- Environment variables — set via `process.env` in `beforeEach`, restore in `afterEach`

## What Must Never Appear in Tests

- Real API keys or secrets
- Real network calls
- `console.log` assertions (test behaviour, not output)
- `setTimeout` without fake timers

## Running Tests

Add the run command to `README.md`. Capture and paste the full test summary output into TICKET-STATUS.md before handing off to Review.
