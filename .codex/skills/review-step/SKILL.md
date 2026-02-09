---
name: review-step
description: Review uncommitted code changes against the current plan step without editing source files. Use after the user implements a step (e.g., via Aider) and wants validation that modifications align with the plan, to map diffs to a specific step, identify gaps or regressions, and update plan progress/history once the user confirms.
---

# Review Step

## Overview

Review staged/unstaged diffs against the active plan step and provide feedback without editing source files. Update the plan file progress/history only after the user confirms the review is satisfactory.

## Operating Rules

1. Do not edit or create source files.
2. Use Git diffs to inspect changes whenever possible.
3. Read and use the plan file (default `PLAN.md`) to map changes to the current step.
4. Only update the plan file after the user confirms the review is good.

## Workflow

1. Confirm the plan file location (default `PLAN.md`) and load it.
2. Identify the current step to review:
   - Prefer `Progress.Current focus` or the top TODO item.
   - If unclear, ask the user to name the task/step.
3. Collect changes with Git:
   - `git status -sb`
   - `git diff` (unstaged)
   - `git diff --staged` (staged)
4. Review changes against the task’s intent and constraints.
5. Report findings:
   - Matches to the task scope
   - Gaps or missing requirements
   - Risky changes or regressions
   - Questions for the user
6. Wait for user confirmation or additional changes.
7. After confirmation, update the plan file:
   - Progress fields (Current focus/Last completed/Next up)
   - TODO checkboxes
   - History entry summarizing the review result

## Review Criteria

Use these checks to structure feedback:
1. Task alignment: changes directly support the current plan task.
2. Completeness: all required sub-tasks are addressed.
3. Safety: no unintended side effects in adjacent areas.
4. Consistency: changes match repo conventions and constraints noted in the plan.
5. Testing: whether existing or new tests should be run (recommend only; do not run unless asked).

## Plan File Update Rules

Only update the plan file after the user explicitly confirms the review is good. Record the review outcome in History with the date, what was reviewed, and whether it was accepted or requires follow-up.

## Handling Unclear Mapping

If the current plan step is ambiguous:
1. Ask the user which TODO item or step to review.
2. If needed, propose a mapping based on diffs and plan context for user confirmation.
