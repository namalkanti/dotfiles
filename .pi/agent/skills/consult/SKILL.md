---
name: consult
description: "Escalate a question or design idea to a stronger model via a one-shot subagent call. Usage: /consult [--model <shorthand>] <question>. Valid shorthands: opus (default), sonnet, sol."
---

# Consult

Escalate a question or idea to a stronger model without compacting or switching the parent session.

## Parsing

1. Strip a leading `--model <shorthand>` flag if present. Valid shorthands: `opus`, `sonnet`, `sol`. Default: `opus`.
2. If an unknown shorthand is given, stop and list the valid options — do not guess.
3. Map shorthand → agent name: `consult-<shorthand>` (e.g. `--model sonnet` → `consult-sonnet`).
4. Everything remaining is the question/idea.

## Packaging the task

Build a self-contained `task` string the consult agent can reason on without access to the session or filesystem. Include:

- The question or idea, stated clearly.
- Any relevant code snippets, data structures, or design context already in the session. Paste the actual content — the agent cannot read files.
- Enough background that the agent can reason without asking follow-up questions.

Keep it tight. Omit session history that isn't directly relevant. If reasoning about a code snippet, include the snippet — not just a filename.

## Calling the agent

```
subagent(single mode):
  agent: "consult-<shorthand>"
  task: <packaged task string>
```

## After the call

The agent's response lands in context automatically. Relay it and be ready for follow-up. If the agent signals insufficient context (e.g. needs to read files, search the codebase), suggest the `/tree` approach instead: branch, `/model <strong>`, discuss interactively, then `/tree` back.
