# Task: Build the `sortie` skill (aider session orchestration) and strip aider out of recon/commander

**Status**: Draft — Ready for execution

## Context

Recon and commander each carry a duplicated, aider-specific section that
generates aider prompts as part of execution/exploration handoff. The user
wants this extracted into a single dedicated skill so that:

- All aider concerns (prompt templates + session lifecycle) live in one place.
- recon and commander become execution-framework-agnostic, with **zero**
  awareness of aider — the user decides which execution skill to invoke, and may
  add sibling execution skills for other frameworks later.
- The mechanical, deterministic scaffolding (write prompt + commands file, spawn
  the aider session, read back the result) is offloaded to the agent, while the
  complex judgment (discussion, hot-swapping to `/code`, the actual coding) stays
  with the user inside the interactive aider session.

The new skill is named **`sortie`** (military-themed, matching recon/commander; a
single mission flown out and back maps to spawning an aider session, doing the
work, and returning).

### The user's aider workflow (what sortie automates)

1. Discuss in a pi session (ad-hoc, or mid-plan via commander) to decide *what*
   to do and *which files* are involved.
2. Pi writes a prompt + a commands file to `.pi/tmp.local/` (`/add` editable
   files, `/read` reference files, `/read` the prompt).
3. User opens aider loading those files + prompt; it starts in `ask` mode (alias
   default) — deliberately read-only.
4. User discusses extensively in aider (ask mode, no code written).
5. When ready, user hot-swaps to `/code` and aider makes changes. No commits.
6. User asks aider for a summary.
7. User brings the summary back to the pi session.
8. Pi reviews: summary + its own `git diff` inspection vs. step intent; updates
   plan / moves on.

**sortie automates only the mechanical parts:** steps 2–3 (write prompt +
commands, spawn the tmux window with everything loaded) and the return half of
7–8 (user says "done"; pi reads aider's persisted chat history for the summary +
runs `git diff`). It does **not** touch the in-aider workflow (steps 4–6), and
the MVP has **no** completion auto-detection and **no** separate summarizer LLM.

## Design Decisions

- **One skill, two prompt concerns.** sortie owns both prompt-template
  generation and session lifecycle. recon/commander own neither.
- **MVP excludes automation.** No watcher process, no auto-detection of aider
  completion, no small-LLM summarizer. The user closes the aider window, returns
  to pi, and manually triggers review. These are explicitly future phases.
- **Launch via interactive shell.** The skill spawns aider with
  `tmux new-window` + `send-keys` into an *interactive* shell so the user's
  `aider` alias resolves (aliases do not exist in non-interactive shells). The
  alias already sets `--chat-mode ask --no-auto-commits --subtree-only` etc.
- **No chat-mode management.** Launch is uniform `ask` mode regardless of prompt
  kind; the user hot-swaps to `/code` themselves. Only prompt *content* differs
  between kinds.
- **Distinct temp filenames.** sortie writes `sortie-*` files in `.pi/tmp.local/`
  (e.g. `sortie-prompt.txt`, `sortie-commands.txt`) so it cannot clobber the
  existing recon/commander aider files during the coexistence/testing period.
- **Stripping is deferred but in-scope.** recon/commander aider sections can
  coexist with sortie during testing (skills load independently, no skill spawns
  another, and distinct filenames avoid collisions). Phase 2 stripping is gated
  on the user validating sortie in practice (Step 4), but lives in this same plan
  so it does not dangle — it must get done.
- **Skills live under** `~/.config/dotfiles/.pi/agent/skills/` (the
  `~/.pi/agent/skills` symlink target). The new skill goes there:
  `sortie/SKILL.md` (+ `sortie/references/`).

## Key Sources

- `~/.config/dotfiles/.pi/agent/skills/commander/SKILL.md` — Contains the
  "Aider Prompts (Temporary)" section (generative + interactive templates,
  saving/confirming convention) to migrate then remove; "Working a Step"
  EXECUTION bullet to genericize; "Reviewing a Step" to verify is tool-agnostic.
- `~/.config/dotfiles/.pi/agent/skills/recon/SKILL.md` — Contains the
  "Interactive Exploration Prompts" section (exploration template + aider
  commands-file generation) to migrate then remove.
- `~/.config/dotfiles/.pi/agent/skills/recon/references/plan-format.md` — Plan
  format both skills follow; mirror its `references/` pattern for sortie.
- `~/.bash_aliases` — `aider` alias (`--chat-mode ask --cache-prompts
  --no-gitignore --no-auto-commits --subtree-only --model
  anthropic/claude-sonnet-4-6 ...`), plus model variants and
  `export AIDER_READ=~/.aider.instructions.md`. Launch must use the interactive
  shell to resolve these.
- `aider --help` — relevant flags: `--load` (run `/commands` on launch),
  `--add`/`--read`/`--file`, `--chat-history-file`, `--message-file`,
  `--yes-always`. Default chat-history file is `.aider.chat.history.md` in repo
  root.

## Proposed Steps

### Phase 1 — Build & validate sortie

1. **Confirm aider launch/capture mechanics** (INVESTIGATION)
   - Goal: Nail down the deterministic primitives the skill's templates encode,
     so launch and read-back are correct.
   - Approach:
     - Verify `tmux new-window` + `send-keys` resolves the interactive `aider`
       alias; settle window naming and whether pi's window stays focused or
       switches to the new window.
     - Decide chat-history capture: **pin** a scoped
       `--chat-history-file .pi/tmp.local/sortie-chat-<ts>.md` at launch (clean,
       known path for pi to read) **vs.** rely on aider's repo-root default
       `.aider.chat.history.md`. *(Answer this choice here, at execution.)*
     - Confirm `/load`, `/add`, `/read` semantics match what the commands-file
       template will assume.
   - Sources: `~/.bash_aliases`, `aider --help`, a scratch tmux/aider run.
   - Status (Step 1): TODO

2. **Write `sortie/SKILL.md`** (EXECUTION)
   - Goal: The skill body, self-documenting and standalone.
   - Approach: Cover —
     - Purpose + hard boundary: owns aider prompt generation + session
       lifecycle; does **not** make the complex decisions (user drives
       discussion/coding inside aider).
     - Two entry modes, both invoked **manually by the user** (skill has no
       knowledge of recon/commander, and is never auto-spawned by them):
       (a) ad-hoc quick-coding — brief discussion → find files → launch;
       (b) pointed at a plan step — read the step, generate from it.
     - Discussion-first before generating anything.
     - Launch lifecycle: write prompt + commands file (`sortie-*` names), spawn
       the tmux window via send-keys, tell the user how to switch in.
     - Return/review handoff: user closes aider, returns, says "done"; skill
       reads the chat-history file (summary) + runs `git diff` and reports.
     - Explicitly note out-of-scope: no completion auto-detection, no separate
       summarizer (future phases).
     - Reference `references/prompt-templates.md` for the templates.
   - Status (Step 2): TODO

3. **Write `sortie/references/prompt-templates.md`** (EXECUTION)
   - Goal: House the aider-specific prompt templates migrated out of the skills.
   - Approach: Include generative (prescriptive/autonomous), interactive
     (guide-mode), and exploration (planning-time collaborative) templates, plus
     the shared "saving and confirming" commands-file convention. Decide whether
     SKILL.md references this file or inlines the templates. *(Answer this
     references-vs-inline choice here, at execution; lean references to keep the
     skill body lean and match the recon/commander pattern.)*
   - Status (Step 3): TODO

4. **Validate sortie in real use** (INVESTIGATION)
   - Goal: Confirm sortie works ad-hoc and against a plan step before stripping
     anything. Gate for Phase 2.
   - Approach: User runs sortie in both modes; capture what works and what needs
     adjustment. Fold fixes back into Steps 2–3 if needed. Only proceed to
     Phase 2 once the user is satisfied.
   - Status (Step 4): TODO

### Phase 2 — Strip aider from recon/commander (gated on Step 4)

5. **Strip aider from `commander/SKILL.md`** (EXECUTION)
   - Goal: commander becomes execution-agnostic with zero aider references.
   - Approach:
     - Remove the entire "Aider Prompts (Temporary)" section.
     - Rewrite the EXECUTION bullet in "Working a Step" to be tool-agnostic:
       discuss the step, hand off to whatever execution skill the user chooses
       (no naming aider); the plan step carries what the executor needs.
     - Verify "Reviewing a Step" (keys off `git diff` + a user-provided summary)
       has no aider-specific wording; adjust if so.
   - Status (Step 5): TODO

6. **Strip aider from `recon/SKILL.md`** (EXECUTION)
   - Goal: recon becomes execution-agnostic with zero aider references.
   - Approach: Remove the "Interactive Exploration Prompts" section (its aider
     file generation now lives in sortie's exploration template); genericize any
     remaining aider mentions.
   - Status (Step 6): TODO

7. **Verify end-to-end coherence** (INVESTIGATION)
   - Goal: Confirm the three skills read cleanly together.
   - Approach: Re-read recon, commander, and sortie; confirm recon/commander
     have zero aider references and read as tool-agnostic; sortie stands alone
     and is invocable both ad-hoc and against a plan step; no dangling
     cross-references.
   - Status (Step 7): TODO

## Notes

- Two choices are deferred to execution by request: (1) Step 1 — pin a scoped
  `--chat-history-file` vs. aider's default; (2) Step 3 — templates in a
  `references/` file vs. inlined in SKILL.md.
- Coexistence risk during testing is minimal: distinct `sortie-*` filenames
  prevent temp-file clobbering; the only soft risk is that, while commander is
  active, the agent could follow commander's inline aider instructions instead
  of sortie's — mitigated by the user invoking sortie explicitly. Phase 2
  removes the duplication entirely.
- Future phases (out of scope here): completion auto-detection and a separate
  small-LLM summarizer in the feedback loop.
