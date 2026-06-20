# Archiving Completed Plans

Commander archives completed plans to `.pi/notes.local/`. Notes are permanent records of what was built — decisions made, learnings from execution, what to carry forward.

**Never delete notes. Only the human deletes.**

## Markers

Every note carries three grep-able sections for cheap scanning without reading full content:

- `## SUMMARY` … `[END_SUMMARY]`
- `## KEY_DECISIONS` … `[END_KEY_DECISIONS]`
- `## KEY_LEARNINGS` … `[END_KEY_LEARNINGS]`

These are consistent with recon notes so all notes in `.pi/notes.local/` are searchable the same way.

## Note Template

```markdown
# [Task Title]

**Type**: Feature / Refactor / Exploration / Mixed
**Started**: YYYY-MM-DD
**Completed**: YYYY-MM-DD
**Status**: Complete
**Value**: [High | Medium | Low | Questionable]

## SUMMARY
One paragraph (2–4 sentences): what was built, key outcome, anything worth flagging for future work.
[END_SUMMARY]

## KEY_DECISIONS
- **Decision**: Brief statement of what was chosen.
[END_KEY_DECISIONS]

## KEY_LEARNINGS
- Learning: Brief insight, gotcha, or pattern to carry forward.
[END_KEY_LEARNINGS]

## What Was Built
- Change or feature: what it does and why it matters.

## Key Decisions (Detailed)
- **Decision**: What was chosen, alternatives considered, rationale, trade-offs.

## Key Learnings (Detailed)
- Discovery or gotcha with enough context to be useful later.

## Critical Files
- `/path/to/file` — What it does, why it matters.

## History Highlights
Major milestones, pivots, or unexpected turns during execution.

## Future Considerations
- Things deferred, known limitations, ideas that came up but weren't in scope.
```

## Value Field

- **High** — key architectural decisions, will be referenced by future plans
- **Medium** — useful context, standard work
- **Low** — minor changes, limited ongoing value
- **Questionable** — little useful information; tell the user it may be deletable and let them decide
