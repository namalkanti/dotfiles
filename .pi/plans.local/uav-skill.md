# Task: Implement the `uav` Skill for Multi-Runner Autonomous Task Dispatch

**Status**: Draft — Ready for execution

## Context
The goal is to create a new skill named `uav` (located at `~/.pi/agent/skills/uav/`) for dispatching autonomous or exploratory tasks with clear ceremony and isolation.
Like `sortie`, `uav` is self-contained without runtime hard dependencies on other skills (such as `commander`). It serves as an active flight controller:
- **Runners**: Supports spawning `pi` (default), `claude` (Claude Code), or `codex` (Codex CLI).
- **Execution Surface**: Default out-of-band execution in a dedicated `tmux` window (`tmux new-window`), with optional in-session execution (for Pi).
- **Workspace Topology**: Default isolated git worktree in `/tmp/uav-<repo>-<task>-<timestamp>` on branch `uav/<task>`, or running directly in current working directory.
- **Context Sharing**: Standard delivery via a structured Mission Brief Markdown file passed at launch (`@mission.md` or prompt argument). For Pi, optional session forking (`--fork`) with prior or post `/compact` is supported.
- **Decision Engine (Pi only)**: Tight integration with `jev_decide` (via `~/.pi/agent/extensions/jev.ts`) as a calibrated co-processor and anti-spiral circuit breaker. External runners (`claude`, `codex`) omit Jev tooling.
- **Return Channel**: Code changes retained on git branches, structured debrief written to `/tmp/uav-<task>-debrief.md`, and deterministic session inspection (via `--session-id` for Pi).

## Design Decisions
- **Skill implementation**: Implemented as a Pi skill (`SKILL.md` + references) rather than an extension, relying on standard Linux tooling (git, tmux, bash).
- **Worktree location**: Kept in `/tmp` (`/tmp/uav-<repo>-<task>`) to keep repository trees completely pristine.
- **Deterministic session tracking**: For Pi spawns, generate a unique session UUID beforehand and pass `--session-id <uuid>` so the parent session knows the exact session file for inspection without heuristic scanning.
- **Pre-flight STOP gate**: Mandatory pause before disk/tmux execution. Flight plan, topology, runner, and verification gates must be explicitly confirmed by the user.

## Key Sources
- `/home/namalkanti/.pi/agent/skills/sortie/SKILL.md` — Pattern for pre-flight ceremony, turn pacing, approval gates, and tmux dispatch.
- `/home/namalkanti/.pi/agent/skills/recon/references/archive.md` — Pattern for markered summaries and notes.
- `/home/namalkanti/.pi/agent/extensions/jev.ts` — Definition and usage of `jev_decide`.
- `/usr/bin/claude` & `/usr/bin/codex` — Installed CLI tools for alternative autonomous runner backends.

## Proposed Steps

1. **Verify Runner CLI Contracts & Invocation Profiles** (INVESTIGATION)
   - Goal: Determine exact launch flags and prompt-passing mechanics for `pi`, `claude`, and `codex`.
   - Status (Step 1): DONE
   - Approach: Inspect CLI flags and test headless/interactive command formulations for tmux execution.
   - Sources: `pi --help`, `claude --help`, `codex --help`.

2. **Create Skill Directory Structure** (EXECUTION)
   - Goal: Initialize directory tree for the new skill.
   - Status (Step 2): DONE
   - Approach: Create `~/.pi/agent/skills/uav/` and `~/.pi/agent/skills/uav/references/`.

3. **Author Runner Specifications (`references/runners.md`)** (EXECUTION)
   - Goal: Document invocation syntax, tmux command lines, and capabilities for each supported runner (`pi`, `claude`, `codex`).
   - Status (Step 3): DONE
   - Approach: Detail command strings, context passing mechanisms (file vs flag), and feature matrices (e.g. Jev support in Pi only).

4. **Author Flight Plan & Debrief Templates (`references/flight-plan.md`)** (EXECUTION)
   - Goal: Standardize pre-flight mission brief and post-flight debrief formats.
   - Status (Step 4): DONE
   - Approach: Detail markdown schemas for `/tmp/uav-<task>-mission.md` (Objective, Scope, Verification, Jev rules) and `/tmp/uav-<task>-debrief.md` (Outcome, Key Decisions, Merging Instructions).

5. **Author Worktree Operations (`references/worktree-ops.md`)** (EXECUTION)
   - Goal: Standardize git worktree lifecycle in `/tmp`.
   - Status (Step 5): DONE
   - Approach: Provide exact shell commands for creation (`git worktree add`), inspection, branch merging (child autonomous vs. parent review), and cleanup (`git worktree remove --force`).

6. **Author Jev Decision Playbook (`references/jev-playbook.md`)** (EXECUTION)
   - Goal: Define calibrated Jev integration rules for Pi child sessions.
   - Status (Step 6): DONE
   - Approach: Write concrete prompt instructions for anti-spiral triggers (>2 turn loop on same error), ambiguous architectural forks, and verification sanity checks without excessive deferrals on trivial decisions.

7. **Author Core Skill Definition (`SKILL.md`)** (EXECUTION)
   - Goal: Create the primary skill file for `uav`.
   - Status (Step 7): DONE
   - Approach: Write `SKILL.md` covering metadata, argument parsing, Pre-Flight Ceremony, mandatory STOP gate, dispatch execution, and post-flight debrief / inspection.

8. **Skill Review and Dry-Run Verification** (INVESTIGATION)
   - Goal: Ensure all relative references resolve and skill instructions are coherent and follow Pi guidelines.
   - Status (Step 8): DONE
   - Approach: Check file paths, verify that `pi` loads the skill without syntax errors, and test prompt generation mechanics.

## History
- **2026-10-23** — Completed Step 8: Skill Review and Dry-Run Verification
  - Tested live tmux dispatch and isolated worktree workflows across all three runners (`pi`, `codex`, `claude`).
  - Resolved Codex skill hijacking by removing `recon`/`commander` symlinks in `~/.codex/skills/`.
  - Clarified `/tmp` placement for mission briefs and debriefs across both worktree and cwd modes.
  - Verified window cleanup, git branch/worktree teardown, and artifact lifecycle.
- **2026-10-23** — Completed Step 7: Author Core Skill Definition (`SKILL.md`)
  - Created `~/.pi/agent/skills/uav/SKILL.md` detailing capabilities, argument parsing, 4 operational phases (pre-flight briefing, mandatory STOP gate, tmux dispatch, post-flight debrief & reintegration), and cross-references.
- **2026-10-23** — Completed Step 6: Author Jev Decision Playbook (`references/jev-playbook.md`)
  - Formulated calibrated schemas for `jev_decide` (choice/score) for anti-spiral detection, architectural forks, and completion sanity gating.
  - Documented strict non-usage for external runners (`claude`, `codex`) and clear anti-patterns.
- **2026-10-23** — Completed Step 5: Author Worktree Operations (`references/worktree-ops.md`)
  - Documented isolated worktree (default in `/tmp/uav-<repo>-<task>-<timestamp>`) and optional in-place / CWD topologies.
  - Authored shell recipes for pre-flight creation, in-flight status inspection, post-flight merge options (merge, rebase, cherry-pick), teardown/cleanup, and edge-case handling.
- **2026-10-23** — Completed Step 4: Author Flight Plan & Debrief Templates (`references/flight-plan.md`)
  - Formatted `/tmp/uav-<task>-mission.md` schema with operational metadata, verification protocols, runner-specific decision rules (Jev vs external circuit breakers), and debrief requirements.
  - Formatted `/tmp/uav-<task>-debrief.md` schema capturing status, file changes, verification outputs, decisions, and integration instructions.
- **2026-10-23** — Completed Step 3: Author Runner Specifications (`references/runners.md`)
  - Documented invocation syntax, options, context delivery, and capabilities for `pi`, `claude`, and `codex`.
  - Defined tmux safety conventions (`exec bash` preservation, naming, working directory anchoring).
- **2026-10-23** — Completed Step 2: Create Skill Directory Structure
  - Created `~/.pi/agent/skills/uav/references/` (tracked in dotfiles repo).
- **2026-10-23** — Completed Step 1: Verify Runner CLI Contracts & Invocation Profiles
  - Confirmed `/usr/bin/pi`, `/usr/bin/claude`, and `/usr/bin/codex` are installed and verified CLI invocation syntax and session options.
  - Pi supports `@mission.md` syntax and `--session-id <uuid>`. Claude supports `--session-id <uuid>` and `--permission-mode`. Codex supports `-C <dir>`, `-s <mode>`, and interactive initial prompts.
  - Re-established `~/.pi/agent/extensions/jev.ts` symlink for Pi child sessions.

## Notes
- `jev_decide` is strictly limited to Pi sessions; Claude and Codex runs must omit Jev references in their generated prompts.
- Interactive mode in tmux should keep the shell open on exit (`pi ...; exec bash`) so users can inspect output even if the agent exits.
