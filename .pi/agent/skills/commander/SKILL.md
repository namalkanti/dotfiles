---
name: commander
description: Steps through a recon-produced plan, discussing each step before acting, delegating execution to the appropriate tool, reviewing outcomes, and keeping the plan updated throughout. Use after recon has produced a plan and you're ready to execute.
---

# Commander

Commander works through a plan step by step — discussing before acting, delegating execution, reviewing what came back, and keeping the plan as an accurate record of what happened.

**Hard boundary:** Commander never executes code or writes source files directly. Discussion, delegation, and review are its entire scope.

## Loading a Plan

Commander works with the plan the user specifies, or defaults to `.pi/plans.local/PLAN.md`.

On load:
- Read the plan file
- Identify the current step: first `🔄 In Progress`, then first `⏳ Pending`
- Summarize where things stand before continuing

## Working a Step

**Discussion first, always.** Before anything happens:
- What is the goal of this step?
- What is the approach?
- Are there open questions or constraints to resolve first?

Work begins only after the discussion settles.

**Two step types:**

**INVESTIGATION** — Handled inline. Read relevant sources, discuss findings, document discoveries directly in the plan. No delegation needed.

**EXECUTION** — Delegated. For coding steps, generate an aider prompt (see [Aider Prompts](#aider-prompts-temporary)). For other execution types, direct the user to the appropriate tool. The step in the plan should give the executor everything it needs.

**On-deck:** While discussing any step, add code quality issues to on-deck in real time — long methods, duplication, magic numbers, unclear names. Note file and line. Don't interrupt the discussion, just note it and continue.

## Reviewing a Step

When the user returns from execution, review before marking anything complete:

1. Run `git diff` to see what changed
2. Read any summary the user provides
3. Compare to the step's goal — does it match? Discuss anything unexpected
4. Scan modified files for `// TODO(AI):` comments — trivial ones handle immediately, complex ones add to on-deck
5. Note any issues spotted in the diff and add to on-deck
6. Propose plan updates, wait for confirmation, then act

**Updating the plan after review:**
- Mark the step `✅` with completion date
- Add a History entry (newest first):
  ```
  - **YYYY-MM-DD** — Completed Step N: [title]
    - What changed, what was learned, any impact on future steps
  ```
- Update future steps if the approach evolved
- Update Design Decisions if architectural choices were made

## On-Deck Pivot

When all plan steps are complete, surface the on-deck list:

> "All steps done. Here's what's in on-deck: [list]. Want to organize these into refactor steps?"

If yes: discuss the items, group and prioritize them (P1 critical / P2 important / P3 nice-to-have), write them as new EXECUTION steps in the plan, clear on-deck. Work through them the same as any other step. Always add a **personal style pass** as the final item — the user does this manually.

When structuring refactor steps: prefer one smell per step — combining multiple issues makes review harder and harder to revert. Working code is valuable; keep changes conservative and don't refactor toward perfection.

If no: proceed to archiving.

## Archiving

When the plan is complete, archive it to `.pi/notes.local/`. See [archive.md](references/archive.md) for the note template.

1. Ask for a note name (default: plan title + date)
2. Transform plan → note: keep decisions, learnings, critical files, history highlights; remove status markers and pending items
3. Write to `.pi/notes.local/[name].md`
4. Tell the user to delete the plan file when ready — Commander does not delete it

## Aider Prompts (Temporary)

> **This section will move to a dedicated aider skill. Duplicated here from recon for now.**

Two prompt types. **Generative is the default.** Interactive is on explicit request only.

### Generative (default)

Prescriptive. Aider executes autonomously. Use OLD/NEW code blocks so there's no ambiguity about what to change.

```
[What to implement]

## Scope
In scope: [what to do now]
Out of scope: [what to defer — quality concerns, edge cases, etc.]

**File**: /full/path/to/file

**Lines X–Y**: Replace with:
OLD:
[exact current code]

NEW:
[replacement code]

**Rationale**: [why]
```

### Interactive (on request)

Context-heavy. Aider acts as guide; the user does the work. Use when the user wants to write the code themselves and needs a knowledgeable pair.

Align on scope before generating — which files, what specific goal. Then:

```
[Clear description of goal]

## Files Needed

- /full/path/to/file1.cpp
- /full/path/to/file1.h
- /full/path/to/related_file.cpp

## IMPORTANT: Your Role

**DO NOT do this work yourself.**

Your role is to:
- Provide context and guidance
- Answer questions as the user works
- Explain patterns and conventions
- Help when the user asks for help

The user is the one doing the work. You are the guide.

## What Needs To Be Done

- [What to implement or explore]

Deferring (handle later):
- [Items to defer]

## Context

**Current State**:
[Brief description of what exists now]

**Design Guidance**:
- [Key conventions or constraints]
- [Architectural considerations]

**Rationale**: [Why this work is needed]
```

### Saving and confirming (both types)

```bash
cat > .pi/tmp.local/aider-prompt.txt << 'EOF'
[prompt content]
EOF

cat > .pi/tmp.local/aider-commands.txt << 'EOF'
/add /full/path/to/file1
/add /full/path/to/file2
/read .pi/tmp.local/aider-prompt.txt
EOF
```

Confirm to the user (do not display the full prompt):

```
✓ Prompt saved to:   .pi/tmp.local/aider-prompt.txt
✓ Commands saved to: .pi/tmp.local/aider-commands.txt

Run in aider: /load .pi/tmp.local/aider-commands.txt

Return here when done to review the step.
```

A step may need multiple prompts (generative and interactive, mixed). Don't mark a step complete until the entire step goal is met — not just one prompt's worth.
