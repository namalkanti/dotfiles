---
name: sortie
description: Aider session orchestration skill. Generates candidate diffs, writes prompt + commands files, launches aider, and summarizes the session on return. Use when handing off a concrete coding or exploration task to an aider session.
---

# Sortie

Sortie handles the mechanical scaffolding around an aider session: generating
initial candidate diffs as a baseline, writing the prompt and commands files,
launching aider, and summarizing the session when the user returns. The
in-session discussion and coding belong to the user.

Sortie is self-contained. It has no awareness of what invoked it and no runtime
dependencies on other skills.

**Turn boundaries & pacing:**
- **Never auto-launch:** Present context confirmation and candidate diffs in turn 1, then **STOP**. Do not write prompt/command files or execute `tmux new-window` until the user explicitly approves.
- **Explicit approval required:** Generating candidate diffs and launching tmux must never happen in the same assistant turn.
- **Strict task scoping:** Keep `sortie-prompt.txt` tightly constrained to the agreed task. Always include explicit Scope and Constraints prohibiting unrequested refactoring, drive-by reordering, or expanding beyond the agreed task boundaries.

---

## Opening: Establish Context

Sortie always opens with a discussion. How much discussion depends on what
context already exists.

### Context-rich entry

Goal, scope, and relevant files are already clear. Confirm the key points
briefly:

- What is the task? (one sentence)
- Which files are editable? Which are read-only reference?
- Any constraints or scope boundaries?

If all three are settled, proceed directly to generating candidate diffs. Present the context and diffs to the user, then **STOP** and wait for approval before launching.

### Cold entry

The user has dropped in with minimal context. Before anything else, establish:

1. **What is the goal?** Concrete and specific — not "improve X" but "extract Y
   into Z so that W."
2. **Which files?** Editable files (will be `/add`ed) and read-only reference
   files (will be `/read` in commands). If unclear, discuss what's likely
   affected.
3. **Scope boundary.** What is explicitly out of scope for this session?

Don't start generating until all three are clear. It's fine to ask two or three
short questions rather than one big form.

---

## Workflow

### 1. Generate candidate diffs

Before writing any files, Pi produces concrete candidate diffs or code sketches
for the proposed change. These become the baseline in the aider session — they
anchor the discussion and let the user say "go ahead" in a single turn if the
diffs look right.

Diffs should be:
- **Concrete**, not descriptive. Actual OLD/NEW code, not prose about what to
  change.
- **Scoped** to the agreed task. Don't generate changes outside the agreed
  boundary.
- **Labeled** with file and approximate line range so the user can orient
  quickly.

Partial diffs are fine. If a change is complex, generate the structural parts
and note what remains for the user to drive in session.

### 2. Write prompt and commands files

Save two files to `.pi/tmp.local/`. Use `sortie-` prefix to avoid collisions
with other skills' files.

```bash
cat > ~/.pi/tmp.local/sortie-prompt.txt << 'EOF'
[prompt content — see prompt-templates.md]
EOF

cat > ~/.pi/tmp.local/sortie-commands.txt << 'EOF'
/add /full/path/to/editable-file1
/add /full/path/to/editable-file2
/read /full/path/to/reference-file
/read ~/.pi/tmp.local/sortie-prompt.txt
EOF
```

`/add` = editable (aider can write to it). `/read` = read-only context. If a
file was `/add`ed and you then `/read` it, aider moves it to read-only — keep
these lists distinct.

See [prompt-templates.md](references/prompt-templates.md) for the Interactive
and Exploration prompt templates.

### 3. Launch aider

Generate a timestamp for the chat history filename, then launch:

Replace `SESSION` with the current tmux session name and `/path/to/workdir`
with the project root.

```bash
TS=$(date +%Y%m%d-%H%M%S)

tmux new-window -t SESSION -n sortie \
  "bash --init-file <(echo 'source ~/.bash_aliases') -i" \; \
  send-keys -t SESSION \
  "cd /path/to/workdir && aider \
    --watch-files \
    --chat-history-file ~/.pi/tmp.local/sortie-chat-${TS}.md \
    --load ~/.pi/tmp.local/sortie-commands.txt" \
  Enter
```

**Why `bash --init-file`:** plain `bash -i -c` does not source `~/.bash_aliases`
in this environment, so the `aider` alias (which sets `--chat-mode ask`,
`--no-auto-commits`, etc.) would not resolve. The `--init-file` form loads
aliases correctly.

**`--chat-mode ask` is the default** via the alias — aider starts read-only.
The user switches to `/code` or uses `/ok` to apply changes. Sortie does not
override this.

Confirm launch to the user:

```
✓ Prompt:    ~/.pi/tmp.local/sortie-prompt.txt
✓ Commands:  ~/.pi/tmp.local/sortie-commands.txt
✓ History:   ~/.pi/tmp.local/sortie-chat-<ts>.md

Launching aider in a new tmux window. Return here when done.
```

### 4. User works in aider

The in-session discussion and coding are entirely the user's domain. Sortie does
not intervene. When the user is done, they close or exit the aider session and
return to the pi session.

### 5. Summarize and review on return

When the user returns:

1. **Spawn the `aider-summarizer` subagent** with the pinned history path:

   ```
   subagent("aider-summarizer", "Summarize: ~/.pi/tmp.local/sortie-chat-<ts>.md")
   ```

2. **Run `git diff`** to see what changed on disk.

3. **Present findings.** Summarize what the session accomplished. Note anything
   unexpected in the diff vs. the original goal.

4. **Hand back to the caller.** If sortie was invoked mid-plan, the calling
   workflow (whatever it is) takes back control with the summary and diff in
   hand. If invoked standalone, discuss next steps with the user.

---

## Non-Goals

- **No in-session participation.** Sortie does not send commands into the aider
  window after launch.
- **No commits.** The alias sets `--no-auto-commits`; sortie does not commit
  anything.
- **No awareness of the calling context.** Whether invoked from a plan workflow
  or directly by the user, sortie behaves identically.
- **No in-session annotation management.** `# AI!` and `# AI?` are aider
  built-ins — sortie does not document or override their behavior.
