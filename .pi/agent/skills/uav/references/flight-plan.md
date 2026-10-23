# Flight Plan & Debrief Templates

This reference defines the schemas for UAV pre-flight mission briefs and post-flight debriefs.

---

## 1. Mission Brief Schema (`/tmp/uav-<task>-mission.md`)

The parent session generates this file in `/tmp` before dispatching the UAV runner. Regardless of workspace topology (`worktree` or `cwd`), mission artifacts always reside in `/tmp` to keep project repositories pristine. It provides complete operational context, boundaries, verification gates, and anti-spiral rules.

```markdown
# Mission Brief: <TASK_TITLE>

## Operational Metadata
- **Task Slug**: <task-slug>
- **Runner**: <pi | claude | codex>
- **Execution Mode**: <tmux-new-window | in-session | tmux-fork>
- **Session UUID**: <uuid>
- **Workspace**: <worktree-path | current-dir>
- **Target Branch**: uav/<task-slug>
- **Dispatched At**: <YYYY-MM-DD HH:MM:SS>

## Objective
<1-2 sentences clearly stating the mission objective and desired end state>

## Acceptance Criteria
- [ ] <Criterion 1>
- [ ] <Criterion 2>
- [ ] All verification commands pass with exit code 0
- [ ] Post-flight debrief written to `/tmp/uav-<task-slug>-debrief.md`

## Scope & Constraints
- **In Scope**:
  - <Permitted file/directory/module 1>
  - <Permitted file/directory/module 2>
- **Out of Scope (Do NOT touch)**:
  - <Forbidden directory/module 1>
  - Do not modify files outside the designated workspace
  - Do not push branches or touch remotes without explicit instruction

## Verification Protocol
Execute the following verification steps before declaring completion:
1. `<build command e.g. cargo check / npm run build>`
2. `<test command e.g. pytest tests/unit / cargo test>`
3. `<lint/format check if applicable>`

## Decision Rules & Circuit Breakers

<!-- IF RUNNER IS PI -->
### Decision Engine (Pi only)
Use the `jev_decide` tool when encountering:
1. **Loop / Anti-Spiral**: If you attempt to fix the same error or failing test more than twice without progress, invoke `jev_decide` to evaluate alternative strategies.
2. **Architectural Forks**: If multiple viable implementations exist with trade-offs not specified in this brief, invoke `jev_decide`.
3. **Completion Confidence**: Before finalizing, invoke `jev_decide` (type: `score`) to evaluate whether all acceptance criteria are met.

<!-- IF RUNNER IS CLAUDE OR CODEX -->
### Circuit Breaker (Claude / Codex)
1. **Anti-Spiral Limit**: If any single error or failing test persists across 3 consecutive tool turns, STOP exploring that path. Document the roadblock in the debrief, revert unsuccessful edits, and present partial results.
2. **Strict Scope**: Do not guess at ambiguous requirements. Document decisions taken under ambiguity in the debrief.

## Mandatory Completion Gate
When finished (or upon hitting a circuit breaker roadblock):
1. Ensure your git changes are committed on branch `uav/<task-slug>`.
2. Write the post-flight debrief to `/tmp/uav-<task-slug>-debrief.md` adhering to the debrief template.
3. Exit cleanly.
```

---

## 2. Post-Flight Debrief Schema (`/tmp/uav-<task>-debrief.md`)

The child runner writes this file to `/tmp` before exiting (regardless of workspace topology). The parent session reads it during the post-flight review phase, and can optionally archive key takeaways to `.pi/notes.local/`.

```markdown
# Mission Debrief: <TASK_TITLE>

## Status
- **Result**: <SUCCESS | PARTIAL | FAILED>
- **Task Slug**: <task-slug>
- **Branch**: uav/<task-slug>
- **Commit SHA**: <head-commit-sha>
- **Completed At**: <YYYY-MM-DD HH:MM:SS>

## Summary of Changes
<Brief overview of what was implemented, fixed, or explored>

### Key Files Modified
- `<path/to/file1>`: <Description of change>
- `<path/to/file2>`: <Description of change>

## Verification Results
- **Command 1**: `<command>` -> <PASSED (exit 0) | FAILED | SKIPPED>
- **Command 2**: `<command>` -> <PASSED (exit 0) | FAILED | SKIPPED>
```text
<paste key test / build output snippet here>
```

## Decisions & Trade-offs
- **<Decision 1>**: <Why this choice was made; alternatives considered>
- **<Decision 2>**: <Any trade-off or deviation from default assumptions>

<!-- IF PI AND JEV WAS USED -->
### Jev Consultations
- Turn X: Question asked -> Jev verdict -> Action taken

## Roadblocks & Unresolved Issues
<None | Description of any blocked items, circuit breaker trips, or follow-up tasks>

## Parent Action / Integration Instructions
To merge changes back to the working branch:
```bash
git checkout <base-branch>
git merge uav/<task-slug>
# Or cherry-pick: git cherry-pick <commit-sha>
# To clean up worktree: git worktree remove --force <worktree-path>
```
```
