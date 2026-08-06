# Build the `sortie` Skill

**Type**: Feature
**Started**: 2025-07-17
**Completed**: 2025-07-17
**Status**: Complete
**Value**: High

## SUMMARY
Built the `sortie` skill for aider session orchestration — candidate diff generation, prompt + commands file writing, aider launch, and return summarization. Stripped aider-specific sections from recon and commander, making both framework-agnostic. Validated end-to-end in a real session (Step 5 used as the test case). Also fixed the `aider` alias from gemini-3.5-flash to gemini-3.6-flash during validation.
[END_SUMMARY]

## KEY_DECISIONS
- **Interactive-first posture.** All sortie sessions are interactive by default. Candidate diffs are a baseline for discussion, not a checklist. Aider applies changes only when explicitly asked — either a specific part or everything at once.
- **`--watch-files` on by default.** Enables `# AI!` / `# AI?` annotations in all sessions. No reason to split watch/non-watch modes.
- **Separate `prompt-templates.md`.** Templates live in `references/prompt-templates.md`, not inline in `SKILL.md`. Pi reads it when generating a prompt. Keeps the skill file concise and templates independently updatable.
- **Pinned chat history file.** `--chat-history-file ~/.pi/tmp.local/sortie-chat-<ts>.md` avoids collisions between sessions and gives `aider-summarizer` an unambiguous path.
- **`aider-summarizer` reused as-is.** The haiku agent built for scribe is fully reusable. No changes needed.
- **Cold vs. context-rich entry.** Sortie adapts discussion depth to available context without referencing or coupling to any calling skill.
[END_KEY_DECISIONS]

## KEY_LEARNINGS
- `bash -i -c` does not source `~/.bash_aliases` in this environment. `bash --init-file <(echo 'source ~/.bash_aliases') -i` is required to resolve the `aider` alias.
- The `## Important` block in the prompt template is critical. Without it, aider tracks diffs as a checklist and pushes the user to apply remaining changes. With it, aider stays passive and surfaces state only when asked.
- `# AI!` and `# AI?` are aider built-ins — no need to document or instruct them in the prompt. Mentioning them in prompts adds noise.
- Aider's ask-mode responses can leave `# AI?` annotation artifacts in files if watch mode isn't active. With `--watch-files` on, annotations are consumed and don't linger.
- Step 5 (strip commander) doubled as the Step 4 validation session — efficient pattern for simple, well-scoped execution steps.
[END_KEY_LEARNINGS]

## What Was Built

- **`~/.config/dotfiles/.pi/agent/skills/sortie/SKILL.md`** — The skill. Covers context-rich vs cold entry, candidate diff generation, prompt + commands file writing, aider launch (with `--watch-files`, pinned history, `bash --init-file`), and return summarization.
- **`~/.config/dotfiles/.pi/agent/skills/sortie/references/prompt-templates.md`** — Interactive prompt template (goal + context + candidate diffs + Important block + scope), Exploration prompt template (goal + sources + questions + exit condition), and summarizer invocation reference.
- **`~/.config/dotfiles/.pi/agent/skills/commander/SKILL.md`** — Stripped "Aider Prompts (Temporary)" section; EXECUTION bullet genericized.
- **`~/.config/dotfiles/.pi/agent/skills/recon/SKILL.md`** — Stripped "Interactive Exploration Prompts" section.
- **`~/.bash_aliases`** — Updated `aider` alias from `gemini/gemini-3.5-flash` to `gemini/gemini-3.6-flash`.

## History Highlights

- Step 1 (investigation) confirmed all mechanics already solved in scribe — launch command, summarizer agent, chat history pinning.
- Step 4 validation surfaced the missing `--watch-files` flag and the need for the Important block in the prompt template. Both fixed before marking done.
- First sortie session (without Important block) had aider complaining when changes weren't applied all at once. Second session with Important block behaved correctly — user applied changes in two selective passes without pushback.
- `aider` alias model updated from 3.5 to 3.6 as a side effect of validation.

## Critical Files

- `~/.config/dotfiles/.pi/agent/skills/sortie/SKILL.md`
- `~/.config/dotfiles/.pi/agent/skills/sortie/references/prompt-templates.md`
- `~/.pi/agent/agents/aider-summarizer.md` — Reused from scribe, unchanged.

## Future Considerations

- **Sortie needs to be symlinked or copied to `~/.pi/agent/skills/`** — same issue as scribe. Skills in dotfiles aren't picked up unless symlinked.
- **Exploration prompt untested.** Only the Interactive prompt was validated. Worth a real test when an exploration use case comes up.
- **`SESSION` placeholder in launch command** — Pi must substitute the actual tmux session name at invocation time. Could be worth automating with `$(tmux display-message -p '#S')`.
