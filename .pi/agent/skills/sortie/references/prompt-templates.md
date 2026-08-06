# Sortie Prompt Templates

Pi fills in these templates when generating a sortie prompt. The filled-in
result is written to `~/.pi/tmp.local/sortie-prompt.txt` and `/read` into aider
via the commands file. These templates are never passed to aider directly.

---

## Interactive Prompt

Use when handing off a concrete coding task. Contains Pi's candidate diffs as
the baseline for the session.

```
## Goal

[One or two sentences. What does this session need to accomplish? Specific and
concrete — not "improve X" but "extract Y into Z so that W."]

## Context

[Relevant background the user needs to orient quickly. What exists now, why the
change is needed, any constraints. Keep it tight — aider has the files open.]

## Candidate Diffs

Pi has generated the following diffs as a starting baseline.

### [filename, lines X–Y]

OLD:
[exact current code]

NEW:
[replacement code]

### [filename, lines X–Y]  (repeat as needed)

OLD:
[exact current code]

NEW:
[replacement code]

[Note if a diff is partial or a sketch — e.g. "structural outline only, fill in
the body" — so the user knows what's complete vs. what needs work in session.]

## Important

This is an interactive session. The diffs above are Pi's suggested starting
point — use them as context and a baseline, not a spec to execute against.

Your role is to discuss, answer questions, and help the user think through the
changes. The user may ask questions, explore alternatives, or deviate from the
suggestions based on what they discover. That's expected and fine.

Track which suggested changes have been applied and where the implementation
diverges from the baseline — surface this only when asked, never proactively.

Apply changes only when explicitly asked — either a specific part or everything
at once. Do not apply anything on your own initiative.

## Scope

In scope:
- [what this session should accomplish]

Out of scope:
- [what to defer — quality concerns, edge cases, follow-on work]
```

---

## Exploration Prompt

Use for read-only codebase research or planning tasks where no code will be
written. No candidate diffs.

```
## Goal

[What question or set of questions does this session need to answer? What
decision or plan should come out of it?]

## Sources

Read the following (already loaded via /read in the commands file):

- [/full/path/to/file — what to look for here]
- [/full/path/to/file — what to look for here]

## Questions to Answer

- [specific question]
- [specific question]
- [specific question]

## What to Bring Back

[What should the user return with? A decision, a list of touchpoints, a proposed
approach? Be explicit so the session has a clear exit condition.]
```

---

## Summarizer Invocation

On return from an aider session, spawn the `aider-summarizer` subagent with the
pinned chat history path:

```
subagent("aider-summarizer", "Summarize: ~/.pi/tmp.local/sortie-chat-<ts>.md")
```

The agent returns:

- **Summary** — what the session accomplished
- **Decisions** — key choices made and their rationale
- **Open Questions** — anything unresolved

Use this output alongside `git diff` to assess what changed vs. the original
goal. The summary is the context bridge — what the diff alone doesn't tell you.
