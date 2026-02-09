---
name: plan
description: Collaborative planning and task breakdown for codebase changes without editing source files. Use when the user wants to explain a goal, brainstorm and clarify scope, break work into steps (and sub-steps), discuss options/risks, and then produce a concrete plan in PLAN.md and on-demand Aider prompts per step.
---

# Plan

## Overview

Collaborate with the user to understand a goal, explore options, and produce a clear, actionable plan. Maintain a human-readable `PLAN.md` and generate step-level Aider prompts on demand.

## Workflow

1. Confirm planning scope and the plan file location (default to `PLAN.md` unless another name is requested).
2. If a plan file already exists, ask to load it and summarize it to reinitialize.
3. Scan the repo for relevant files and constraints.
4. Discuss goals, constraints, risks, and options; clarify assumptions.
5. Break the work into steps and sub-steps; refine as the discussion proceeds.
6. Continuously capture newly discovered context, decisions, and ideas in `PLAN.md`.
7. Draft a TODO-oriented plan and update `PLAN.md`.
8. If implementation is desired, generate a concise Aider prompt for the next step only.

## Operating Rules

1. Do not edit or create source files.
2. The only file to write or edit is the plan file (default `PLAN.md`, or another name if the user specifies).
3. Use repo scanning to inform the plan, not to implement changes.
4. If the user asks to implement changes, produce Aider prompts step-by-step instead of editing code.

## Repo Scan Guidance

Use fast, read-only discovery to locate relevant areas before planning.

Suggested commands:
1. `rg --files` to list files or match patterns.
2. `rg "keyword|pattern"` to find references.
3. `ls` or `find` for directory structure.

Summarize findings as inputs to the plan.

## PLAN.md Format

Keep the plan concise and TODO-oriented. Use this template unless the user requests another format:

```markdown
# Plan

Last updated: YYYY-MM-DD

## Context
- ...

## Goals
- ...

## Constraints
- ...

## Decisions
- ...

## Open Questions
- ...

## TODO
- [ ] ...
- [ ] ...

## Progress
- Status: Not started | In progress | Blocked | Done
- Current focus: ...
- Last completed: ...
- Next up: ...

## History
- YYYY-MM-DD: ...

## Notes
- ...
```

Include a short "Last updated: YYYY-MM-DD" line near the top.
Update the Progress section whenever the user asks to reflect current state or after each planning session.
Append brief entries to History when notable context, decisions, or plan changes occur.
When new information supersedes existing content, update the core sections (Context/Goals/Constraints/Decisions/Open Questions/TODO/Progress) to keep them current, and record the change in History.

## Reinitialize From Existing Plan

If the plan file exists:
1. Ask whether to load it.
2. Summarize the current plan, open questions, and TODOs.
3. Continue planning from that baseline and update the plan file with any new findings and a History entry.

## Aider Prompt Generation

When the user wants to implement changes:
1. Provide a single, clean prompt that Aider can execute for the next step only.
2. Ensure each step is small enough to implement and verify with Aider, without over-splitting into too many tiny steps.
3. Include: brief goal, files to edit, key constraints, and ordered TODOs.
4. Do not include speculative steps; stick to the plan.
