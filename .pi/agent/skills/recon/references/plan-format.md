# Plan File Format

Recon's authoring guide for writing plan files. Write plans to
`.pi/plans.local/`.

**The plan must be self-documenting.** A downstream executor reads the plan
file alone and follows it without consulting recon, this guide, or any other
skill. Write every field so it stands on its own.

Plans are source-agnostic: "sources" and "steps" may involve code, documents,
web pages, specs, or anything else investigated.

## Template

```markdown
# Task: [Goal in one line]

**Status**: Draft — Ready for execution

## References
(Optional — related plans or notes. Omit the section if none.)
- `.pi/plans.local/related-plan.md` — How it relates
- `.pi/notes.local/prior-discovery.md` — Related prior work

## Context
What recon learned. Enough that the executor needs no prior knowledge.
- Problem description and why it matters
- Current state of the relevant sources
- Key findings from information gathering
- Constraints and considerations

## Design Decisions
(Optional — decisions already made during recon. Omit if none.)
- **Decision**: What was chosen and the rationale.

## Key Sources
The sources identified during recon, each with why it matters. Accept paths, URLs, or spec references.
- `/path/to/file` — What it is, why it's relevant
- `https://example.com/doc` — Documentation to read before implementing
- `spec/section-3` — Constraint or reference it supplies

## Proposed Steps
Ordered steps for the executor. Each step is self-contained.

1. **[Step title]** (INVESTIGATION)
   - Goal: What needs to be understood
   - Approach: How to investigate
   - Sources: What to examine
   - Status: ⏳ Pending

2. **[Step title]** (EXECUTION)
   - Goal: What needs to be produced or changed
   - Approach: High-level approach
   - Status: ⏳ Pending

## Notes
- Insights worth carrying forward
- Unknowns to resolve during execution
- Risks to watch for
```

## Field Notes

**Status** — `Draft` while recon is still shaping it; `Ready for execution`
once recon hands it off. Recon-authored plans are drafts the executor may
refine further.

**Step types** — Two neutral types:
- `INVESTIGATION` — understand something before acting (read sources, confirm
  assumptions, gather context).
- `EXECUTION` — produce or change something (write, build, edit, generate).

Use the type that fits each step. A plan may be all investigation, all
execution, or a mix.

**Status markers** — `⏳ Pending` / `🔄 In Progress` / `✅ Done` so progress
is trackable across sessions.
