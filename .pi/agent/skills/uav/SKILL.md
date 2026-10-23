---
name: uav
description: Autonomous task dispatch orchestrator with git worktree isolation, multi-runner support (pi, claude, codex), calibrated Jev decision-making, and structured debriefing.
---

# UAV — Autonomous Task Dispatch Orchestrator

`uav` prepares, isolates, and launches autonomous agent runs to execute bounded coding or exploratory missions. It enforces strict pre-flight ceremony, non-destructive worktree isolation, and structured debriefing upon completion.

---

## Capabilities & Defaults

- **Runners**: `pi` (default), `claude`, `codex`. See [runners.md](references/runners.md).
- **Workspace Topology**: Isolated git worktree in `/tmp/uav-<repo>-<task>-<ts>` on branch `uav/<task>` (default), or in-place current directory (`cwd`). See [worktree-ops.md](references/worktree-ops.md).
- **Execution Surface**: Dedicated tmux window (`tmux new-window`) by default, with optional in-session execution for `pi`.
- **Decision Engine (Pi only)**: Calibrated `jev_decide` co-processor for anti-spiral detection and architectural forks. See [jev-playbook.md](references/jev-playbook.md). (Omitted for Claude/Codex).
- **Return Channel**: Post-flight debrief schema at `/tmp/uav-<task>-debrief.md`. See [flight-plan.md](references/flight-plan.md).

---

## Invocation & Options

Trigger syntax:
`/uav <task-description> [flags]`

### Flags
- `--runner <pi|claude|codex>`: Agent backend (default: `pi`).
- `--topology <worktree|cwd>`: Workspace isolation mode (default: `worktree`).
- `--mode <tmux|in-session|fork>`: Execution mode (default: `tmux`). `in-session` and `fork` are valid only when runner is `pi`.
- `--model <name>`: Model override passed to runner CLI.

*Examples*:
- `/uav "Implement LRU cache eviction in cache.rs"` (defaults: pi, worktree in /tmp, tmux)
- `/uav "Refactor error types" --runner claude` (Claude Code runner in worktree)
- `/uav "Audit auth middleware" --runner codex` (Codex CLI in worktree)
- `/uav "Profile query benchmarks" --topology cwd` (Pi in-place without worktree)

---

## Operational Workflow

When `uav` is invoked, follow these phases sequentially:

### Phase 1: Pre-Flight Briefing Preparation

1. **Parse & Slugify**: Convert the user's task description into a short, descriptive slug `<task-slug>` (e.g. `lru-cache`, `auth-audit`).
2. **Generate Session UUID**: Generate a random UUID for deterministic session tracking:
   ```bash
   python3 -c "import uuid; print(uuid.uuid4())"
   ```
3. **Establish Workspace**:
   - If `worktree` (default):
     - Check repository root: `REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")`
     - Path: `/tmp/uav-${REPO_NAME}-${TASK_SLUG}-$(date +%s)`
     - Branch: `uav/${TASK_SLUG}`
     - Create worktree: `git worktree add -b uav/${TASK_SLUG} ${WORKTREE_PATH} HEAD`
   - If `cwd`: Target directory is the current working directory.
4. **Draft Mission Brief**:
   - Write the mission brief to `/tmp/uav-${TASK_SLUG}-mission.md` following the schema in [flight-plan.md](references/flight-plan.md). (Mission files always live in `/tmp` to keep project repositories pristine, even when using `cwd` mode).
   - Tailor the brief to the selected runner: include Jev instructions only if runner is `pi`.
   - Include explicit acceptance criteria and project verification commands (e.g. `cargo test`, `pytest`).

---

### Phase 2: Pre-Flight STOP Gate (Mandatory)

**Do NOT launch the runner or execute tmux dispatch until the user explicitly confirms.**

Present the flight plan summary to the user:

```markdown
### 🛫 UAV Pre-Flight Confirmation

- **Task**: <task title>
- **Runner**: <pi | claude | codex>
- **Execution Mode**: <tmux new-window | in-session | tmux fork>
- **Workspace**: `<workspace-path>` (Branch: `uav/<task-slug>`)
- **Session UUID**: `<session-uuid>`
- **Mission Brief**: `/tmp/uav-<task-slug>-mission.md`
- **Verification Gates**:
  1. `<test command>`
  2. `<build/lint command>`

Ready to launch? (Confirm to dispatch)
```

**STOP.** Wait for the user to approve before proceeding to Phase 3.

---

### Phase 3: Launch & Dispatch

Once confirmed:

1. **Formulate Tmux Command** (see [runners.md](references/runners.md)):
   - **Pi**:
     ```bash
     tmux new-window -n "uav:${TASK_SLUG}" -c "${WORKTREE_PATH}" \
       "pi --session-id ${SESSION_UUID} @/tmp/uav-${TASK_SLUG}-mission.md; exec bash"
     ```
   - **Claude Code**:
     ```bash
     tmux new-window -n "uav:${TASK_SLUG}" -c "${WORKTREE_PATH}" \
       "claude --session-id ${SESSION_UUID} --permission-mode auto \"\$(cat /tmp/uav-${TASK_SLUG}-mission.md)\"; exec bash"
     ```
   - **Codex CLI**:
     ```bash
     tmux new-window -n "uav:${TASK_SLUG}" -c "${WORKTREE_PATH}" \
       "codex -s workspace-write -a never \"\$(cat /tmp/uav-${TASK_SLUG}-mission.md)\"; exec bash"
     ```

2. **Execute Dispatch**:
   - Run the tmux command via bash.
   - Inform the user that the UAV is airborne:
     - Name of tmux window (`uav:<task-slug>`).
     - How to attach / switch: `tmux select-window -t uav:<task-slug>`.
     - Instruct the user to return when the mission completes or debrief is generated.

---

### Phase 4: Post-Flight Debrief & Reintegration

When the user signals completion (or upon returning from the tmux window):

1. **Read Mission Debrief**:
   - Check if `/tmp/uav-${TASK_SLUG}-debrief.md` exists and read its contents.
2. **Inspect Changes**:
   - Run git diff to inspect changes made on `uav/${TASK_SLUG}` vs `HEAD`.
   - Run verification tests if not already verified.
3. **Present Integration & Cleanup Options**:
   - Present a concise summary of results and trade-offs from the debrief.
   - Review changes with the user.
   - **Only after the user approves the work (or decides to abandon it)**, provide or execute the cleanup commands:
     ```bash
     # 1. Merge or cherry-pick approved changes
     git merge uav/${TASK_SLUG}

     # 2. Close the UAV tmux window if still open (targets the window created during dispatch)
     tmux kill-window -t "uav:${TASK_SLUG}" 2>/dev/null || true

     # 3. Teardown temporary worktree & branch
     git worktree remove --force "${WORKTREE_PATH}"
     git branch -d uav/${TASK_SLUG}
     ```
