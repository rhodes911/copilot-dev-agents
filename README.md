# copilot-dev-agents

A reusable, four-agent development lifecycle system for GitHub Copilot Agent Mode. One command adds it to any repo. Drop a ticket number in chat, pick an agent, and let Copilot handle scoping, planning, building, and reviewing your work.

---

## Requirements

Before you start, make sure you have:

- **VS Code** (latest stable)
- **GitHub Copilot extension** with **Agent Mode enabled**
  - `Settings → Extensions → GitHub Copilot → Enable Agent Mode`
- **Git** installed and on your `PATH`

---

## Add to a New Project

Run this in the root of any Git repo. It adds the agent system as a submodule, copies all files into place, and commits everything automatically.

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/rhodes911/copilot-dev-agents/master/bootstrap.ps1 | iex
```

**macOS / Linux (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/rhodes911/copilot-dev-agents/master/bootstrap.sh | bash
```

That's it. You'll see 14 files committed to your repo.

---

## Update an Existing Project

When the agent system itself is updated, pull the latest version into your repo:

**Windows:**
```powershell
git submodule update --remote .copilot-dev-agents
.\.copilot-dev-agents\sync-agents.ps1 -TargetRepo .
git add .
git commit -m "chore: update copilot-dev-agents to latest"
```

**macOS / Linux:**
```bash
git submodule update --remote .copilot-dev-agents
bash .copilot-dev-agents/sync-agents.sh .
git add .
git commit -m "chore: update copilot-dev-agents to latest"
```

The sync script only updates files that came from the agent system. It never overwrites your own index files or customisations.

---

## Using the Agents

### Opening the Agent Dropdown

1. Open Copilot Chat (`Ctrl+Alt+I` / `Cmd+Alt+I`)
2. Click the **agent selector** (the `@` or dropdown) at the top of the chat panel
3. Pick the agent for the current stage of your work

### Context Attachment

For all agents **except Discovery**, attach the ticket folder to the chat context:

- In Copilot Chat, click **"Attach context"** (paperclip icon)
- Select the folder: `docs/tickets/TICKET-{NUMBER}/`

This gives the agent access to TICKET-STATUS.md, DEV-PLAN, and REVIEW files without you pasting anything.

---

## The Four Stages

### Stage 1 — Discovery

**When to use:** You have a new feature request, bug report, or any piece of work that doesn't have a ticket yet.

**What to say:**
```
Add a user authentication system using JWT tokens
```
or
```
Bug: the search endpoint returns 500 when the query is empty
```

No ticket number or context attachment needed — Discovery handles everything from scratch.

**What it does:**
1. Asks one clarifying question if the request is genuinely ambiguous (otherwise proceeds)
2. Identifies or creates the parent epic in `docs/epics/`
3. Creates an epic branch: `git checkout -b epic/EPIC-{NUMBER}`
4. Creates `docs/tickets/TICKET-{NUMBER}/TICKET-STATUS.md` from the template
5. Reads the actual source files to investigate constraints (never guesses)
6. Fills in the Investigation Findings section of the ticket
7. Updates both `INDEX.md` files
8. Offers a **"Send to Planner"** handoff button

**You get back:** A fully populated `TICKET-STATUS.md` with interface impact, dependency analysis, test impact, and env var requirements — all evidence-based.

---

### Stage 2 — Planner

**When to use:** A ticket exists and has been investigated. You need an architecture plan before writing code.

**What to say:**
```
ticket=TICKET-00001
```

**Attach context:** `docs/tickets/TICKET-{NUMBER}/`

**What it does:**
1. Reads TICKET-STATUS.md (never assumes what it contains)
2. Reads every source file referenced in the Discovery findings
3. Produces `docs/tickets/TICKET-{NUMBER}/DEV-PLAN-{NUMBER}.md` containing:
   - Affected modules table (file, change type, description)
   - Exact interface and schema changes
   - New dependencies with justification
   - Numbered, independently testable acceptance criteria
   - Test plan and mock strategy
   - Risks
4. Updates TICKET-STATUS.md to mark Planning complete
5. Offers **"Send to Build"** or **"Back to Discovery"** handoff buttons

**You get back:** A `DEV-PLAN-{NUMBER}.md` that Build can implement against without ambiguity.

---

### Stage 3 — Build

**When to use:** A DEV-PLAN exists and planning is marked complete.

**What to say:**
```
ticket=TICKET-00001
```

**Attach context:** `docs/tickets/TICKET-{NUMBER}/`

**What it does:**
1. Reads the full DEV-PLAN before touching any code
2. Reads every file it is about to change (never overwrites based on assumptions)
3. Follows a strict TDD loop: write the smallest unit of production code, write a test, run it, fix until green, repeat
4. Mocks all external interactions — no real API calls in tests
5. Adds any new env vars to `.env.example`
6. Updates Build Notes in TICKET-STATUS.md
7. Offers **"Send to Review"** or **"Back to Planner"** handoff buttons

**You get back:** Working, tested code with a passing test suite. Build won't hand off until tests are green.

---

### Stage 4 — Review

**When to use:** Build is complete and tests are passing.

**What to say:**
```
ticket=TICKET-00001
```

**Attach context:** `docs/tickets/TICKET-{NUMBER}/`

**What it does:**
1. Runs the full review checklist (code quality, test coverage, interface integrity, documentation)
2. Runs the test suite and captures the output as UAT evidence
3. If issues are found: creates `docs/tickets/TICKET-{NUMBER}/REVIEW-{NUMBER}.md` with a numbered issue list and hands back to Build
4. If the ticket is the **final ticket in an epic**: verifies epic-level acceptance criteria, updates `EPIC-STATUS.md` to `done`, creates an `EPIC-STORY` file, and opens a PR from `epic/EPIC-{NUMBER}` into `main`
5. If everything passes: marks the ticket `done` and signs off

**You get back:** Sign-off with UAT evidence captured in TICKET-STATUS.md, or a clear numbered issue list to send back to Build.

---

## Complete Workflow — Step by Step

Here is a concrete example from "I have an idea" to "merged to main".

### 1. Start a new feature

Open Copilot Chat, select **Discovery**, and describe what you want:

```
Add rate limiting to the API — max 100 requests per minute per IP address
```

Discovery will:
- Check `docs/epics/INDEX.md` and either create a new epic or assign to an existing one
- Create `git checkout -b epic/EPIC-00003`
- Check `docs/tickets/INDEX.md` and create `docs/tickets/TICKET-00007/TICKET-STATUS.md`
- Read your existing middleware and config files to understand the constraints
- Document findings in TICKET-STATUS.md

At the end you will see a **"Send to Planner"** button. Click it.

### 2. Get the architecture plan

Copilot Chat switches to **Planner** automatically. Attach `docs/tickets/TICKET-00007/` to context.

Planner reads the ticket and your source files, then produces `docs/tickets/TICKET-00007/DEV-PLAN-00007.md` with the full plan.

Click **"Send to Build"**.

### 3. Implement and test

Build is now active. Attach `docs/tickets/TICKET-00007/` to context.

Build reads the DEV-PLAN, writes the code and tests together, runs the suite, and updates TICKET-STATUS.md.

Click **"Send to Review"**.

### 4. Review and sign off

Review is now active. Attach `docs/tickets/TICKET-00007/` to context.

If this is the only ticket in the epic, Review will:
- Run the checklist
- Capture UAT evidence
- Update EPIC-STATUS.md
- Open a PR: `epic/EPIC-00003` → `main`

You merge the PR.

---

## Ticket and Epic Structure

### Numbering Convention

Numbers are assigned sequentially. Before creating a new ticket or epic, check the relevant `INDEX.md` for the next available number.

| Format | Example |
|--------|---------|
| Epic | `EPIC-00001` |
| Ticket | `TICKET-00001` |
| Dev Plan | `DEV-PLAN-00001` |
| Review | `REVIEW-00001` |

### File Layout

```
docs/
  epics/
    INDEX.md                          <- list of all epics + status
    EPIC-{NUMBER}/
      EPIC-STATUS.md                  <- epic scope, AC, status
      EPIC-STORY-{NUMBER}.md          <- created by Review on epic sign-off
  tickets/
    INDEX.md                          <- list of all tickets + status
    TICKET-{NUMBER}/
      TICKET-STATUS.md                <- filled by Discovery (and updated by each agent)
      DEV-PLAN-{NUMBER}.md            <- written by Planner
      REVIEW-{NUMBER}.md              <- created by Review if issues found
```

### The Discussion Section

Every agent deliverable must include a `## Discussion` section. This is how acceptance criteria are proved, not just stated:

```markdown
## Discussion

### Acceptance Criteria
- AC1: Rate limiting middleware returns 429 when limit exceeded
- AC2: Limit resets every 60 seconds

### Evidence
- AC1 evidence: Ran `npm test -- rate-limit` --> 8 tests passed, 0 failed
- AC2 evidence: Integration test with 2-second window confirmed reset behaviour

### Notes / Risks
- Redis required for distributed deployments -- noted in DEV-PLAN
```

---

## Epic Branch Policy

Every epic gets exactly one branch. All tickets in that epic are committed to the same branch.

```bash
# Created automatically by Discovery:
git checkout main && git pull && git checkout -b epic/EPIC-{NUMBER}

# Merged automatically by Review on final ticket sign-off:
# PR: epic/EPIC-{NUMBER} -> main
```

Never work directly on `main`. Never create a branch per-ticket.

---

## What the Sync Installs

| Destination | What |
|-------------|------|
| `.github/agents/` | `discovery.agent.md`, `planner.agent.md`, `build.agent.md`, `review.agent.md` |
| `.github/instructions/` | `agent-system.instructions.md`, `documentation.instructions.md`, `testing.instructions.md` |
| `docs/templates/` | `EPIC-STATUS-TEMPLATE.md`, `TICKET-STATUS-TEMPLATE.md`, `DEV-PLAN-TEMPLATE.md` |
| `docs/epics/` | `INDEX.md` (created if absent) |
| `docs/tickets/` | `INDEX.md` (created if absent) |

The sync script will **never overwrite** your existing `INDEX.md` files or anything outside these directories.

---

## File Structure After Bootstrap

```
your-repo/
  .copilot-dev-agents/       <- the submodule (pinned to a specific commit)
  .github/
    agents/
      discovery.agent.md
      planner.agent.md
      build.agent.md
      review.agent.md
    instructions/
      agent-system.instructions.md
      documentation.instructions.md
      testing.instructions.md
  docs/
    epics/
      INDEX.md
    templates/
      DEV-PLAN-TEMPLATE.md
      EPIC-STATUS-TEMPLATE.md
      TICKET-STATUS-TEMPLATE.md
    tickets/
      INDEX.md
```

---

## Customising for Your Project

The agents follow the conventions already present in your codebase. You don't need to configure them — they read your files first and adapt.

If you want to add project-specific rules, add an instruction file in `.github/instructions/` with an `applyTo` front-matter glob. For example, to add rules that apply to all TypeScript files:

```markdown
---
applyTo: "**/*.ts"
---

# TypeScript Conventions

- Always use strict null checks
- Prefer named exports over default exports
```

You can also add a `copilot-instructions.md` file under `.github/` for global rules. The agent system's `agent-system.instructions.md` (which has `applyTo: "**"`) will merge with it automatically — you don't need to touch it.

---

## Troubleshooting

### Agents don't appear in the dropdown

- Confirm you are on VS Code with the GitHub Copilot extension installed
- Confirm Agent Mode is enabled: `Settings → Extensions → GitHub Copilot → Enable Agent Mode`
- Ensure `.github/agents/*.agent.md` files exist at the **repo root** (not in a subfolder)
- Reload VS Code

### Bootstrap fails with "access denied" or "rate limited"

GitHub CDN can cache the raw URL for a few minutes after a new push. Wait 5 minutes and retry. If the issue persists, use the exact commit SHA URL:

```powershell
irm https://raw.githubusercontent.com/rhodes911/copilot-dev-agents/{SHA}/bootstrap.ps1 | iex
```

### PowerShell execution policy blocks the script

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Then re-run the one-liner.

### Submodule already exists error

If `.copilot-dev-agents` already exists as a directory (not a submodule), remove it first:

```powershell
Remove-Item -Recurse -Force .copilot-dev-agents
```

Then re-run bootstrap.

### Agent says "No ticket number — rejecting"

All agents except Discovery require a ticket number. Either:
- Say `ticket=TICKET-00001` in your message, or
- Attach the `docs/tickets/TICKET-{NUMBER}/` folder to context

### Sync overwrites my customised agent files

It won't. The sync script uses `Copy-Item` from the submodule source, which means it will overwrite the standard agent files when you run an update. If you have local customisations to agent files, keep them in a separate file (e.g. a project-specific instruction file) rather than editing the agent files directly.
