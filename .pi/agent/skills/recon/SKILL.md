---
name: recon
description: Task planning skill that identifies and describes work, gathers information from relevant sources (code, docs, web, specs), and produces structured, self-documenting plan files for downstream execution. Use at the start of any task to scope it and generate a plan — even when the goal is already clear.
---

# Recon

Recon investigates a task, gathers the information needed to understand it, and
produces a self-documenting plan file that a downstream skill executes.

Sources are not code-only — a task may involve code, documents, web pages,
specs, or anything else worth investigating.

**Hard boundary:** recon never executes or implements. Its only output is plan
files (and, when archived, discovery notes). Producing a plan is success;
writing code is out of scope.

## Workflow

1. **Understand the task.** Ask clarifying questions about goals, constraints,
   and scope. Understand the *why*, not just the *what*.

2. **Review prior work.** Search `.pi/notes.local/` for related past
   investigation before re-discovering it. See
   [archive.md](references/archive.md) for the search method.

3. **Gather information.** Investigate the relevant sources. Read what matters,
   map how the pieces connect, identify touchpoints and constraints. Share
   findings as you go.

4. **Discuss scope and propose structure.** Summarize what you found. Propose a
   plan structure — a single plan or several — and explain the reasoning. Get
   agreement on the structure before drafting the plan.

5. **Present the plan for review.** First read
   [plan-format.md](references/plan-format.md) — the eventual *file* must follow
   it. Then present an outline that enumerates *every* step (typed
   INVESTIGATION/EXECUTION), with the choices that determine what each step does
   made explicit. Keep the outline at review granularity — the steps and the
   reasoning behind them, not file-only scaffolding (status markers, verify
   clauses, verbatim bodies like full prompts). The user reviews the steps
   themselves; a step they cannot fully understand from the outline is a signal
   to add detail, not to write. Iterate in the conversation, not the file. Get
   explicit approval to write.

6. **Write the plan(s).** Once the step outline is approved, write plan file(s)
   to `.pi/plans.local/`. Read [plan-format.md](references/plan-format.md) and
   follow it exactly — the plan must stand on its own for the executor.

**Guardrail:** two gates stand before anything reaches disk. First, agree on the
plan *structure* (step 4). Then, get explicit approval of the plan's *steps* —
every step enumerated, with the choices shaping each made explicit (step 5).
Structure agreement is not step approval; do not treat the former as license to
write. Do not write plan files until the step outline is approved.

## Multiple Plans

When a task is large or spans independent areas, split it into multiple
top-level plans rather than one sprawling plan. These are independent peers,
not a parent-child hierarchy. Name them descriptively by area:

```
.pi/plans.local/
├── notifications-backend.md
├── notifications-frontend.md
└── notifications-integration.md
```

Each plan should be executable on its own. Note ordering or dependencies in the
plans' `References` sections when they exist.

**When to split.** Split when parts have distinct boundaries that can progress
independently. For example, a "migrate database" task splits cleanly into schema
design, data-layer rewrite, dual-write, and cutover — each workable on its own.

Keep-as-one when the pieces are tightly coupled. For example, "add real-time
notifications" where backend (Socket.io), frontend (WebSocket client + UI), and
integration (event wiring) all need to advance together — splitting them forces
one plan to block on another that hasn't even started. A single plan lets them
be defined and executed coherently.

## Working from an Existing Plan or Draft

Recon may be pointed at an existing plan or draft to refine. Read it first,
build on what's there, and don't duplicate investigation already done.

Two outcomes:
- **Refine in place** — shape it into a ready-for-execution plan (same file).
- **Split** — break it into multiple plans and archive the original as a note.

**Reference resolution.** When a plan references another file:
1. Try the exact path.
2. If not found, try the alternate location
   (`.pi/plans.local/` ↔ `.pi/notes.local/`).
3. If still not found, ask the user.

**Never delete plans or drafts.** Either make them executable or archive them as
notes. Only the human deletes.

## Archiving

**On explicit request only.** Never archive automatically. The user decides
when the investigation is worth preserving as a note.

When asked, write the investigation itself (findings, decisions, unknowns) to
`.pi/notes.local/`. See [archive.md](references/archive.md) for the note
template, markers, and value ratings.

## Interactive Exploration Prompts

> **Temporary:** this will move to its own prompt-generation skill. Kept here
> for now.

**On explicit request only.** When the user asks to explore collaboratively
(rather than recon investigating alone), generate a prompt that guides *them*
through the sources. Never generate these proactively or suggest them by
default.

The generated prompt should:
- List the specific sources to examine (full paths / URLs).
- State the questions to answer and what to look for.
- Make clear the user drives the exploration; the prompt's role is to guide and
  answer questions, not to do the investigation.

### Generating files for aider

Save two files to `.pi/tmp.local/`:

1. **The prompt** — the generated exploration prompt text.

   ```bash
   cat > .pi/tmp.local/recon-exploration-prompt.txt << 'EOF'
   [generated prompt content]
   EOF
   ```

2. **A companion commands file** — `/add` for each source, then `/read` for the
   prompt.

   ```bash
   cat > .pi/tmp.local/aider-commands.txt << 'EOF'
   /add /full/path/to/source1
   /add /full/path/to/source2
   /read .pi/tmp.local/recon-exploration-prompt.txt
   EOF
   ```

Then point the user at it:

```
✓ Prompt saved to:   .pi/tmp.local/recon-exploration-prompt.txt
✓ Commands saved to: .pi/tmp.local/aider-commands.txt

Run in aider: /load .pi/tmp.local/aider-commands.txt
Come back and share your findings when ready.
```

When the user returns with findings, fold them into the workflow at step 4
(discuss scope and propose structure).
