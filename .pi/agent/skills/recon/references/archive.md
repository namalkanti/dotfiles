# Archiving & Prior-Work Search

Two halves of one note format: how recon **writes** notes (archiving) and how
it **reads** them (prior-work search). Notes live in `.pi/notes.local/`.

## Markers

Every note carries three grep-able markered sections. They make notes cheap to
scan without reading full content:

- `## SUMMARY` … `[END_SUMMARY]`
- `## KEY_DECISIONS` … `[END_KEY_DECISIONS]`
- `## KEY_LEARNINGS` … `[END_KEY_LEARNINGS]`

## Searching Prior Work (Review Older Results)

Run at the start of discovery to avoid re-investigating known ground. Two
phases, cheap first:

**Phase 1 — Scan summaries.** Grep the `SUMMARY` marker across all notes and
read a few lines of context after each. ~100 tokens per note, enough to judge
relevance.

```bash
grep -rn -A 10 "^## SUMMARY$" .pi/notes.local/
```

**Phase 2 — Deep read.** Read the full content of only the 2-3 most relevant
notes.

**When to search:** starting new discovery; the user mentions prior related
work; the task touches an area likely to have prior art. **Skip** for trivial
tasks or brand-new areas with no plausible prior work.

Prior notes inform discovery but don't replace it — notes show *past decisions
and learnings*, the sources show *current state*.

## Writing a Note (Archive)

Archive recon work — the investigation itself, separate from any execution.
Trigger when discovery is complete or a session wraps up worth preserving.

**Never delete notes or plans. Only the human deletes.**

```markdown
# [Task Title] — Recon

**Type**: Recon / Discovery
**Started**: YYYY-MM-DD
**Completed**: YYYY-MM-DD
**Status**: Complete
**Value**: [High | Medium | Low | Questionable]

## SUMMARY
One paragraph (2-4 sentences): what was investigated, key findings, and what
plans were created.
[END_SUMMARY]

## KEY_DECISIONS
- **Decision**: Brief statement of what was chosen.
[END_KEY_DECISIONS]

## KEY_LEARNINGS
- Finding: Brief insight, gotcha, or risk identified.
[END_KEY_LEARNINGS]

## Task Description
What the user wanted to accomplish.

## Investigation Summary
Which sources were examined and how.

## Key Findings (Detailed)
- What was learned, discovered, or confirmed.

## Decisions Made (Detailed)
- **Decision**: What was chosen, alternatives considered, rationale.

## Plans Created
- `.pi/plans.local/plan.md` — What it covers.

## Unknowns & Risks
- What needs further investigation; what to watch for.

## References
- Related notes or external documentation.
```

### Value Field

- **High** — key decisions, complex investigation, referenced by plans.
- **Medium** — useful context, standard discovery.
- **Low** — minimal findings, mostly dead ends.
- **Questionable** — little useful information; tell the user it may be
  deletable. Flag it, but let the user decide — recon never deletes.
