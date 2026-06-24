# Task: Escalate "help me think" moments from a local parent model to a stronger model, without compaction/cache pain

**Status**: Ready for execution

## References
- `~/.pi/agent/skills/recon/references/plan-format.md` — format this plan follows.

## Context

While working in a local Qwen session (or any cheap/local parent model), the
user wants to escalate hard ideation/design questions to a stronger model. The
current workaround — compact → `/model` swap → discuss → swap back — forces
recompaction and destroys the parent's prompt cache every time, and wastes
tokens carrying excessive context into the strong model.

Two complementary modes solve this, both fully inside pi:

- **Non-interactive consult** — one-shot. The parent packages a tight,
  self-contained context summary + question and hands it to a stronger model
  via the existing `subagent` tool. The subagent inherits nothing from the
  parent (only the `task` text), so context stays tight and the parent session
  is never compacted. The answer is relayed back into the parent's context
  automatically (subagent tool result). Strong model chosen per call via a
  `--model` flag. **This is the only thing built.**
- **Interactive escalation** — back-and-forth with the strong model using pi's
  native `/tree` branching + `/model` switch. Returning to the parent branch,
  pi attaches a summary of the strong-model branch at the return point.
  **Nothing to build — documentation + a one-time smoke test.**

Current state of relevant sources:
- The **subagent extension** (`examples/extensions/subagent/`) is already
  installed: agents symlinked into `~/.pi/agent/agents/`, extension symlinked
  into `~/.pi/agent/extensions/subagent/` (both from read-only `/opt`). Spawns
  each agent as a separate `pi` subprocess with isolated context, streams
  progress, returns final output to the parent (auto relay-back), 50 KB/task
  cap.
- A subagent's model comes only from agent frontmatter (`agents.ts` parses
  `model`; `index.ts:295` → `if (agent.model) args.push("--model", agent.model)`).
  The tool schema has no per-call `model` field.
- `settings.json` `enabledModels` is the authoritative model list; its non-Qwen
  entries are the five consult targets.
- `default-model.ts` forces Qwen on `session_start`, so the parent is usually
  Qwen but may be anything.

Constraints:
- `/opt` is read-only/shared — do not edit it.
- Author in `~/.config/dotfiles/.pi/agent/`, surface via per-file symlinks into
  `~/.pi/agent/` (the existing pattern).
- Agent `name:` must be lowercase / hyphens / no dots.

## Design Decisions
- **No vendoring, no patch.** Per-call model override would require forking the
  whole extension (~1141 lines) to change ~5. Rejected for maintenance /
  upstream-drift risk. Instead: one agent file per model, model in frontmatter.
  Multi-model coverage with zero forked code.
- **Hand-write the agent files, no generator script.** The five files are
  near-identical; syncing them is a trivial multi-file edit any LLM does
  instantly. A regen script optimizes a non-problem.
- **Consult agents are pure reasoners (no tools).** The parent must supply the
  info. If the agent lacks context it says so and returns — signalling the user
  to switch to `/tree`. No file-grabbing / rabbit-holing.
- **`--model` is an explicit flag, not a positional token** — model names
  ("opus"/"gpt") routinely appear inside questions and would misparse.
- **Skill prompt is parent-agnostic** — parent is usually Qwen but may be
  anything.
- **Interactive mode uses native `/tree`, not `--fork`.** `/tree` branch
  summaries relay results back into the parent branch automatically; `--fork`
  makes a separate file with no relay-back path. Branch-compact automation
  rejected (trivial two-keystroke op).

## Key Sources
- `~/.pi/agent/agents/` — where consult agent symlinks go; `reviewer.md` is a
  code-review prompt contrast for the ideation `consult` prompt.
- `~/.config/dotfiles/.pi/agent/{agents,skills}/` — author location.
- `/opt/pi-coding-agent/examples/extensions/subagent/{index.ts,agents.ts,README.md}`
  — the unmodified tool being called.
- `~/.pi/agent/settings.json` `enabledModels` — model shorthand→ID source.
- `/opt/pi-coding-agent/docs/sessions.md` — `/tree`, Branch Summaries.
- `/opt/pi-coding-agent/docs/compaction.md` — branch summarization internals.
- `/opt/pi-coding-agent/docs/skills.md` — skill format, `/skill:name`,
  `disable-model-invocation`.

Model map (shorthand → agent name → frontmatter model):

| `--model` | agent name | `model` |
|---|---|---|
| `opus` (default) | `consult-opus` | `claude-opus-4-8` |
| `sonnet` | `consult-sonnet` | `claude-sonnet-4-6` |
| `gemini` | `consult-gemini` | `gemini-3.5-flash` |
| `gpt5-4` | `consult-gpt5-4` | `gpt-5.4` |
| `gpt5-5` | `consult-gpt5-5` | `gpt-5.5` |

## Proposed Steps

1. **Write the five consult agent files** (EXECUTION)
   - Goal: five pure-reasoner agents differing only in `name:` / `model:` /
     (model mention in `description`). No `tools:` line — cannot read/grep.
   - Approach: for each model-map row, create
     `~/.config/dotfiles/.pi/agent/agents/consult-<shorthand>.md` with
     frontmatter (`name`, `description` mentioning the model, `model`) plus the
     shared thinking-partner system prompt below. Symlink each into
     `~/.pi/agent/agents/consult-<shorthand>.md`.
   - Shared system prompt (identical across all five):
     - You are a thinking partner; reason about the provided question/idea.
     - Surface tradeoffs, failure modes, missing considerations, alternatives;
       lead with the bottom line, then reasoning. Think — don't just validate.
     - You have no tools and no access to the caller's files or history; reason
       only on what was provided.
     - If the provided context is insufficient, say so explicitly and state
       what's missing rather than guessing (signals the caller to switch to a
       `/tree` interactive escalation).
     - Be concise; the caller is itself a capable model.
   - Verify: each agent appears in the subagent tool's available list; a
     throwaway `subagent` call to `consult-opus` runs on `claude-opus-4-8`;
     agents have no file tools.
   - Status (Step 1): DONE

2. **Write the `/consult` skill** (EXECUTION)
   - Goal: `/consult --model <shorthand> <question>` → package context, call the
     unmodified `subagent` tool with `consult-<shorthand>`.
   - Approach: create
     `~/.config/dotfiles/.pi/agent/skills/consult/SKILL.md` (frontmatter
     `name: consult`, description covering ideation escalation), symlink the dir
     into `~/.pi/agent/skills/`. Skill body instructs the parent model to:
     1. Parse a leading `--model <shorthand>` flag (valid: `opus`, `sonnet`,
        `gemini`, `gpt5-4`, `gpt5-5`; default `opus`; reject unknown with the
        valid list). Map to agent `consult-<shorthand>`.
     2. Treat everything after the flag as the question/idea.
     3. Package a self-contained `task` string: question + just enough context
        that the tool-less agent needs no session history. Summarize tightly;
        include substance, not file paths (agent cannot read files).
     4. Call `subagent` single mode: `{ agent: "consult-<shorthand>", task }`.
     5. Relay the returned analysis (already in context for follow-up). If the
        agent reports insufficient context, suggest the `/tree` path (Step 3).
   - Verify: `/consult --model sonnet <q>` runs `consult-sonnet`; `/consult <q>`
     defaults to opus; analysis lands back in the parent context.
   - Status (Step 2): TODO

3. **Document and smoke-test interactive `/tree` escalation** (EXECUTION)
   - Goal: a documented procedure for the back-and-forth case, plus a one-time
     validation that pi behaves as the docs claim. No code, no skill, no agent.
   - Approach: keep the procedure as a short personal note (or a
     `disable-model-invocation` reminder skill only if a reminder is wanted):
     1. At a hard-thinking moment, `/tree` and branch from the current point.
     2. If the branch context is bloated, `/compact` within the branch (affects
        only this branch's leaf, not the parent branch).
     3. `/model <strong>` (e.g. `claude-opus-4-8`). Discuss interactively.
     4. `/tree` back to the parent branch point; choose **summarize with custom
        focus** so the discussion condenses and attaches at the return point.
     5. `/model` back to the parent model if needed; continue.
   - Smoke test (before relying on it): run one real `/tree` round-trip and
     confirm (a) per-branch `/model` switch works and (b) the branch summary
     attaches at the return point. If behavior differs, revisit.
   - Status (Step 3): TODO

## Notes
- Ordering: Step 1 → Step 2 are sequential (the skill references the agents).
  Step 3 is independent — do anytime.
- `opus` is the strongest enabled model and the default consult target, fitting
  the token-cost rationale (escalate to the best available, infrequently).
- Verified (not a blocker): existing dotfiles extensions use bare pi-package
  imports with no `node_modules` up the tree and load fine, so pi injects its
  own resolver. (Relevant only if vendoring were ever reconsidered — it is not.)
- Risk: Step 3 rests on `/tree` branch-summary + per-branch model-switch
  behaving as documented; the smoke test exists to catch any divergence before
  the workflow is relied on.
