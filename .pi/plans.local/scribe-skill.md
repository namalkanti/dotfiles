# Task: Build the `scribe` skill (markdown document creation and refinement)

**Status**: Draft — Ready for execution

## Context

The user wants a dedicated skill for creating and refining markdown documents,
analogous to how `sortie` handles aider-based coding sessions. The skill runs
standalone — it has no knowledge of other skills, though commander may hand off
to it.

The core workflow is pi-first: brainstorm, structure, and draft in a pi
conversation while pi writes/edits the markdown file directly. At some point the
user may choose to hand off to aider for interactive refinement, specifically
leveraging aider's **watch mode** — which lets the user annotate inline inside
the document (e.g. `AI: this paragraph sounds off`) and have aider respond in
place, rather than describing issues through chat.

The return loop is simpler than sortie: no summary or git diff review needed
because the document is the artifact — the user just returns to pi to continue
if more work remains.

**Out of scope for this plan:** Google Docs export (additive later step).

## Design Decisions

- **Pi is the primary execution path.** pi writes/edits the file directly for
  brainstorming and initial drafting. Aider is an optional handoff, not the
  default.
- **Skill is self-contained.** No references to commander or any other skill.
  Other skills may invoke scribe, but scribe has no awareness of them.
- **Markdown only.** Google Docs export is deferred to a future plan.
- **Watch mode is the key aider differentiator.** Inline `AI:` annotations in
  the file are more natural for prose feedback than describing issues through
  chat. The exact mechanics (flags, comment format, launch pattern) are an open
  investigation item.

## Key Sources

- `~/.bash_aliases` — `aider` alias and model config; launch must use
  interactive shell to resolve aliases.
- `aider --help` — watch mode flags and relevant options.
- `~/.config/dotfiles/.pi/agent/skills/sortie/SKILL.md` — Reference for launch
  lifecycle pattern (tmux window, commands file convention, tmp file naming).
  Note: sortie may not exist yet; see sortie-skill plan.
- `.pi/plans.local/sortie-skill.md` — Context on the sortie pattern being
  paralleled.

## Proposed Steps

1. **Understand aider watch mode mechanics** (INVESTIGATION)
   - Goal: Nail down exactly how watch mode works before designing the skill
     around it.
   - Approach: Check `aider --help` for the watch mode flag. Confirm the `AI:`
     comment convention (or whatever the actual annotation syntax is). Verify
     whether it can coexist with a `/load` commands file. Determine what a
     minimal launch command looks like for a markdown file in watch mode.
   - Sources: `aider --help`, `~/.bash_aliases`, aider docs if needed.
   - Status (Step 1): TODO

2. **Settle the aider handoff workflow** (INVESTIGATION)
   - Goal: Decide the concrete handoff pattern given what watch mode looks like.
   - Approach: Determine whether a commands file + context preamble written to
     `.pi/tmp.local/` is needed, or whether launching aider directly on the
     document is sufficient. Settle what the user does to trigger the handoff
     (what pi outputs), and what returning to pi looks like.
   - Depends on: Step 1.
   - Status (Step 2): TODO

3. **Write `scribe/SKILL.md`** (EXECUTION)
   - Goal: The skill body, self-documenting and standalone.
   - Approach: Cover —
     - Purpose and hard boundary: owns markdown document creation and
       refinement; pi-first drafting, optional aider handoff.
     - Pi drafting phase: brainstorm and structure discussion, pi writes/edits
       the file directly.
     - Aider handoff decision point: when it makes sense (user wants inline
       annotation, wants to write sections themselves) vs. staying in pi.
     - Aider launch lifecycle settled in Step 2.
     - Return/continue: user comes back to pi, reads current doc state,
       continues if needed.
     - Explicit non-goals: no Google Docs export, no sortie-style summarizer.
   - Depends on: Steps 1–2.
   - Status (Step 3): TODO

4. **Write `scribe/references/` if warranted** (EXECUTION)
   - Goal: House any reference material that would bloat SKILL.md.
   - Approach: If the aider launch template or watch-mode instructions are
     substantial, extract to `references/watch-mode.md`. If small, fold into
     SKILL.md directly.
   - Depends on: Step 3.
   - Status (Step 4): TODO

5. **Validate in real use** (INVESTIGATION)
   - Goal: Confirm the skill works for a real document creation session before
     declaring done.
   - Approach: Run through a session — pi drafting phase plus at least one
     aider watch mode handoff. Capture what works and what needs adjustment;
     fold fixes back into Steps 3–4 if needed.
   - Status (Step 5): TODO

## Notes

- The exact aider watch mode syntax is unknown — Step 1 is a hard prerequisite
  for Steps 2–3.
- sortie may not exist yet when this executes; Step 1 should check whether it
  exists and read it for launch pattern reference if so.
- Google Docs export is intentionally deferred. When added later, it will likely
  be a new plan that extends scribe rather than a revision to this one.
