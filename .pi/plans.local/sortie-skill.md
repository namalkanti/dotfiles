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
  the aider session, read back the result, run summarizer) is offloaded to the agent,
  while the complex judgment (discussion, hot-swapping to `/code`, the actual coding)
  stays with the user inside the interactive aider session.

The new skill is named **`sortie`** (military-themed, matching recon/commander; a
single mission flown out and back maps to spawning an aider session, doing the
work, and returning).

### The user's aider workflow (what sortie automates)

1. Discuss in a pi session (ad-hoc, or mid-plan via commander) to decide *what*
   to do and *which files* are involved.
2. Pi (as the stronger model) generates initial candidate diffs / partial diffs or code
   sketches for the proposed change to anchor the task.
3. Pi writes a prompt + a commands file to `.pi/tmp.local/` (`/add` editable
   files, `/read` reference files, `/read` the prompt). The prompt explicitly instructs
   aider NOT to auto-apply edits immediately, but to start in read-only discussion mode.
4. User opens aider loading those files + prompt; it starts in `ask` mode (alias
   default) — deliberately read-only.
5. User discusses in aider (ask mode) using Pi's diffs as the starting baseline.
   If the diffs are good as-is, the user can immediately say "go ahead" / `/ok` in a single turn.
6. When ready, user hot-swaps to `/code` (or uses `/ok`) and aider applies changes. No commits.
7. User closes aider window and returns to pi session.
8. Pi automatically invokes a lightweight `aider-summarizer` subagent to parse the
   session chat history (`.aider.chat.history.md` or pinned chat history file).
9. Pi reviews: subagent summary + `git diff` inspection vs. step intent; updates plan / moves on.

**sortie automates only the mechanical parts:** steps 2–3 (write prompt with Pi diffs +
commands, spawn the tmux window) and steps 8–9 (user returns; pi runs summarizer subagent
on chat history + runs `git diff`). It does **not** touch the in-aider discussion/coding (steps 4–6).

## Design Decisions

- **One skill, two prompt categories (Interactive & Exploration).** No separate "generative"
  vs. "interactive" distinction. All execution prompts are **Interactive Prompts** containing Pi-generated candidate diffs/context. Exploration prompts remain read-only for research/planning.
- **Strict Read-Only Prompt Safeguard.** Because aider/LLMs lean aggressively toward applying code immediately, prompt templates must explicitly instruct aider to remain in discussion/read-only mode until the user explicitly commands execution.
- **Subagent Summarizer in MVP.** Reuses the proven subagent summarizer pattern (demonstrated in `scribe`'s implementation) to summarize session decisions upon return.
- **Zero Skill-to-Skill Dependencies.** `scribe` is referenced during plan design for architectural pattern reuse, but `sortie` will have ZERO runtime dependency on `scribe` or vice versa. Each skill remains fully self-contained.
- **Launch via interactive shell.** The skill spawns aider with `tmux new-window` + `send-keys` into an *interactive* shell so the user's `aider` alias resolves (aliases do not exist in non-interactive shells).
- **Distinct temp filenames.** sortie writes `sortie-*` files in `.pi/tmp.local/` (e.g. `sortie-prompt.txt`, `sortie-commands.txt`).

## Key Sources

- `~/.config/dotfiles/.pi/agent/skills/scribe/SKILL.md` — Reference for the `aider-summarizer` subagent pattern and chat-history reading.
- `~/.config/dotfiles/.pi/agent/skills/commander/SKILL.md` — Contains the "Aider Prompts (Temporary)" section to migrate then remove.
- `~/.config/dotfiles/.pi/agent/skills/recon/SKILL.md` — Contains the "Interactive Exploration Prompts" section to migrate then remove.
- `~/.bash_aliases` — `aider` alias (`--chat-mode ask --cache-prompts --no-gitignore --no-auto-commits --subtree-only ...`), plus model variants and `export AIDER_READ=~/.aider.instructions.md`.
- `aider --help` — relevant flags: `--load`, `--add`/`--read`/`--file`, `--chat-history-file`.

## Proposed Steps

### Phase 1 — Build & validate sortie

1. **Confirm aider launch/capture & summarizer mechanics** (INVESTIGATION)
   - Goal: Nail down launch primitives and subagent summary integration.
   - Approach:
     - Verify `tmux new-window` + `send-keys` resolves the interactive `aider` alias.
     - Confirm chat-history path pin (`--chat-history-file .pi/tmp.local/sortie-chat-<ts>.md`) vs `.aider.chat.history.md`.
     - Test subagent invocation against an existing `.aider.chat.history.md` file using the `scribe`-style prompt structure.
   - Sources: `~/.bash_aliases`, `scribe/SKILL.md`, `aider --help`.
   - Status (Step 1): TODO

2. **Write `sortie/SKILL.md`** (EXECUTION)
   - Goal: Self-documenting, standalone skill file.
   - Approach: Cover —
     - Single responsibility: prompt generation + session lifecycle + return summarization.
     - Pi diff-generation step prior to writing prompt.
     - Safeguard prompting rules (prevent auto-execution in `ask` mode).
     - Handoff & return workflow (invoking `aider-summarizer` subagent + `git diff`).
     - Zero hard dependencies on other skills.
   - Status (Step 2): TODO

3. **Write `sortie/references/prompt-templates.md`** (EXECUTION)
   - Goal: House the prompt templates and summarizer prompt.
   - Approach:
     - **Interactive Prompt Template**: embeds Pi's generated candidate diffs/context; explicitly enforces read-only discussion first; supports single-turn approval (`/ok`) or multi-turn refinement before `/code`.
     - **Exploration Prompt Template**: read-only codebase exploration / planning.
     - **Summarizer Subagent Prompt**: standalone prompt definition for summarizing `.aider.chat.history.md`.
   - Status (Step 3): TODO

4. **Validate sortie in real use** (INVESTIGATION)
   - Goal: Confirm end-to-end flow (Pi diff generation -> launch -> aider session -> user return -> subagent summary + git diff).
   - Approach: Test ad-hoc and against a plan step. Fix any issues in Steps 2–3.
   - Status (Step 4): TODO

### Phase 2 — Strip aider from recon/commander (gated on Step 4)

5. **Strip aider from `commander/SKILL.md`** (EXECUTION)
   - Goal: Make commander execution-framework-agnostic.
   - Approach: Remove "Aider Prompts (Temporary)" section; genericize step working/reviewing bullets.
   - Status (Step 5): TODO

6. **Strip aider from `recon/SKILL.md`** (EXECUTION)
   - Goal: Make recon execution-framework-agnostic.
   - Approach: Remove "Interactive Exploration Prompts" section; genericize remaining mentions.
   - Status (Step 6): TODO

7. **Verify end-to-end coherence** (INVESTIGATION)
   - Goal: Re-read recon, commander, and sortie to confirm zero leftover references and total independence.
   - Status (Step 7): TODO

## Aider Capability Notes

Discovered during recon; informs how `sortie`'s prompt templates and skill documentation describe available tools and features.

### Alias / launch config capabilities
- **`--vim`** — enables vi keybindings in prompt-toolkit input.
- **`Ctrl-X Ctrl-E`** — opens `$EDITOR` (Neovim) to compose current prompt, sends on save/quit.
- **`--notifications` / `--notifications-command`** — desktop notification when LLM finishes.

### Mid-session commands worth knowing
- **`/context <intent>`** — aider auto-identifies and adds files needed for a given request.
- **`/web <url>`** — scrapes URL to markdown in chat.
- **`/save`** — writes commands file reconstructing session's `/add` state.
- **`/editor` / `Ctrl-X Ctrl-E`** — open Neovim for long structured prompt composition.
- **`/think-tokens <budget>` / `/reasoning-effort <level>`** — adjust model reasoning mid-session.
- **PDF support** — `/add file.pdf` works with Sonnet/Gemini models.

### Third handoff pattern (manual escape hatch)
`/copy-context [instructions]` + `--copy-paste` mode enable a manual architect-style loop using a web UI model (Claude.ai / ChatGPT) as planner, returning formatted edits for aider to parse and apply. Documented as an ad-hoc pattern in SKILL.md.
