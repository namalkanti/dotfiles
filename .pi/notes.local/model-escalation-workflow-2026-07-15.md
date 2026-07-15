# Model Escalation Workflow

**Type**: Feature
**Started**: 2026-06-21
**Completed**: 2026-07-15
**Status**: Complete
**Value**: High

## SUMMARY
Built a two-mode escalation workflow for promoting hard questions from a local parent model (Qwen) to stronger models without compacting or destroying the parent session. Non-interactive mode: five pure-reasoner consult agents (`consult-opus`, `consult-sonnet`, `consult-gemini`, `consult-gpt5-4`, `consult-gpt5-5`) plus a `/consult` skill that packages context tightly and delegates via the existing `subagent` tool. Interactive mode: native `/tree` branching with per-branch model switching — confirmed working, no code needed.
[END_SUMMARY]

## KEY_DECISIONS
- **One agent file per model, not a forked extension.** Per-call model override would require forking ~1141 lines of the subagent extension to change ~5. Rejected for maintenance/drift risk.
- **No generator script for agent files.** Five near-identical files; syncing is trivial. A regen script optimizes a non-problem.
- **Consult agents are pure reasoners — no tools.** Agent cannot read files or search. Parent must supply substance (snippets, context). If more is needed, use `/tree`.
- **`--model` is an explicit flag, not positional.** Model names appear inside questions and would misparse if positional.
- **Interactive mode uses native `/tree`, not `--fork`.** `/tree` relays branch summaries back automatically; `--fork` has no relay-back path.
- **Snippet inclusion is preferred over file paths.** Small relevant code can be inlined in the task string; full file reads or searches require the `/tree` approach.
[END_KEY_DECISIONS]

## KEY_LEARNINGS
- **YAML frontmatter colons break unquoted description strings.** `description: ... Usage: /consult ...` — the colon after `Usage` causes a YAML parse error. Pi silently rejects the skill. Always quote descriptions containing colons, or validate with `python3 -c "import yaml; yaml.safe_load(...)"` after writing.
- **Pi silently drops skills with invalid frontmatter.** No error surfaced in the TUI; `/skill:name` just echoes as a message. The diagnostic is `pi --skill <path> --print "list your skills"`.
- **`~/.pi/agent/skills` is already a symlink to dotfiles.** No per-skill symlink needed — files authored in `~/.config/dotfiles/.pi/agent/skills/` are immediately discoverable.
- **`ln -sf <src> <dest>` when dest exists as a directory places the symlink inside dest.** Creates a nested symlink instead of replacing the directory. Use `ln -sfn` or remove the target first.
[END_KEY_LEARNINGS]

## What Was Built
- **Five consult agent files** — `~/.config/dotfiles/.pi/agent/agents/consult-{opus,sonnet,gemini,gpt5-4,gpt5-5}.md`. Each has model-specific frontmatter and a shared pure-reasoner system prompt. Symlinked into `~/.pi/agent/agents/`.
- **`/consult` skill** — `~/.config/dotfiles/.pi/agent/skills/consult/SKILL.md`. Parses `--model <shorthand>` flag (default `opus`), packages a self-contained task string with the question and any relevant snippets, calls `subagent` single mode, relays result back. Accessible via the existing `~/.pi/agent/skills` symlink.
- **`/tree` interactive escalation** — no code. Procedure: `/tree` to branch, optionally `/compact` within branch, `/model <strong>`, discuss, `/tree` back with summarize, `/model` back if needed.

## Key Decisions (Detailed)
- **No extension fork.** The subagent extension hardcodes model from agent frontmatter (`index.ts:295`). Overriding per-call would require forking ~1141 lines to change ~5 — maintenance burden and upstream-drift risk not worth it.
- **Snippet-inclusive consult.** Small relevant code snippets are fine to inline in the task string. The agent cannot read files, but pasted content works. Full codebase search requires `/tree`.

## Critical Files
- `~/.config/dotfiles/.pi/agent/agents/consult-opus.md` — template for all consult agents; others differ only in name/model/description.
- `~/.config/dotfiles/.pi/agent/skills/consult/SKILL.md` — the `/consult` skill.
- `~/.pi/agent/settings.json` `enabledModels` — authoritative model shorthand source.
- `/opt/pi-coding-agent/examples/extensions/subagent/index.ts` — subagent extension (read-only); line 295 is the model injection point.

## History Highlights
- Step 1 (agent files) completed 2026-06-21 before this plan was worked through commander.
- Step 2 (consult skill) hit a YAML parse failure: unquoted description with a colon caused silent skill rejection. Several debugging turns before root cause identified.
- Step 3 (tree escalation) smoke-tested manually and confirmed working.

## Future Considerations
- If the subagent extension gains a per-call `--model` flag upstream, the five agent files collapse to one.
- A `disable-model-invocation` variant of the consult skill could be added if auto-loading becomes noisy.
