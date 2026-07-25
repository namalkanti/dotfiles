# Build the `scribe` skill (markdown document creation and refinement)

**Type**: Feature
**Started**: 2025-07-16
**Completed**: 2025-07-16
**Status**: Complete
**Value**: High

## SUMMARY
Built the `scribe` skill for pi-driven document creation and refinement, with markdown as the universal drafting medium and optional aider handoff. Also created a reusable `aider-summarizer` haiku agent that reads `.aider.chat.history.md` and summarizes discussion context — applicable to scribe, sortie, and any future aider-integrated skill. Both were validated end-to-end in a real session.
[END_SUMMARY]

## KEY_DECISIONS
- **Pi-first, aider optional.** Pi is the primary author and orchestrator; aider handoff is user-initiated, not skill-initiated.
- **Markdown as universal draft medium.** Markdown may be the final form or a stepping stone to export — export mechanics are deferred.
- **Always start with discussion.** Scribe never begins writing before settling document type, format, structure posture, and file location.
- **aider-summarizer is a separate haiku subagent.** Keeps expensive model tokens out of pedantic aider turn summarization; reusable across skills.
- **Full path passed to aider-summarizer.** Avoids ambiguity regardless of invocation context.
- **Launch via `bash --init-file`** to resolve the `aider` alias (plain `bash -i -c` does not load `.bash_aliases` in this environment).
- **Context loaded via `/read` in a commands file.** `/read` injects read-only context; `/add` makes files editable — important distinction.
- **Watch mode is optional.** Even within an aider session; user handles `--chat-mode` switch manually.
[END_KEY_DECISIONS]

## KEY_LEARNINGS
- `bash -i -c` does not source `~/.bash_aliases` in this environment — `bash --init-file <(echo 'source ~/.bash_aliases') -i` is required to resolve the `aider` alias.
- `~/.pi/agent/agents/` is a real directory, not symlinked to dotfiles (unlike `skills/`). Agents written to dotfiles must be manually copied over until the user sets up a symlink.
- Aider's `/read` command moves a file from editable to read-only if it was already `/add`ed — worth knowing when building commands files.
- Watch mode annotation syntax in markdown: `# AI:`, `# AI!`, `# AI?` (line-comment prefix required; `AI!` triggers immediately, `AI?` asks without editing).
[END_KEY_LEARNINGS]

## What Was Built

- **`~/.config/dotfiles/.pi/agent/skills/scribe/SKILL.md`** — The scribe skill. Covers always-discussion-first opening, pi's dual role as brainstorm partner and orchestrator, freewrite posture (dump → reorganize), drafting phases, aider handoff (user-initiated), watch mode, commands file context loading, and the aider-summarizer return loop.
- **`~/.config/dotfiles/.pi/agent/agents/aider-summarizer.md`** (+ copy to `~/.pi/agent/agents/`) — Haiku agent that reads a caller-provided chat history path and returns a structured summary of decisions and open questions.

## Key Decisions (Detailed)

- **Pi does not decide when to hand off to aider.** Earlier draft included guidance on when handoff makes sense — removed. That judgment belongs to the user.
- **Markdown may be the final form.** Skill does not assume export is always the end goal.
- **aider-summarizer uses haiku** because aider sessions often contain many pedantic back-and-forth turns that don't warrant expensive model attention. The summary output (decisions + open questions) is what pi needs to continue, not a transcript.
- **No fixed summary length.** Initial draft capped summary at 2–4 sentences — too restrictive for long sessions. Replaced with "synthesize, don't transcribe."

## Critical Files

- `~/.config/dotfiles/.pi/agent/skills/scribe/SKILL.md` — The skill itself.
- `~/.config/dotfiles/.pi/agent/agents/aider-summarizer.md` — Haiku summarizer agent (also at `~/.pi/agent/agents/aider-summarizer.md`).

## History Highlights

- Steps 1–2 (watch mode investigation + handoff workflow) folded into one discussion — enough was known to proceed directly to writing.
- `aider-summarizer` agent added mid-plan after realizing the return loop needed cheap summarization, not inline high-model work. Generalized immediately for use beyond scribe.
- Launch command required two iterations: `bash -i -c` didn't load aliases; `bash --init-file` fixed it.
- Validation session confirmed full flow: alias resolution, context loading via commands file, aider session, summarizer subagent.

## Future Considerations

- **Google Docs / Confluence export** — intentionally deferred. Will be a new plan extending scribe.
- **`~/.pi/agent/agents/` symlink** — user plans to symlink this to dotfiles so agents don't need manual copying.
- **sortie will adopt `aider-summarizer`** — noted in sortie plan; no action needed here.
- **Watch mode validated** — `# AI!` annotation triggered aider in-place. Watch mode activity appears as file edits, not chat turns, so it won't show up in the summarizer output — that's expected. Trivial turns (e.g. "What is this?" / "this is a markdown file") are correctly stripped by the summarizer.
