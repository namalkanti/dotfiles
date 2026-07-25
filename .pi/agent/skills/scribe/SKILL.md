# Scribe

Scribe is the skill for creating and refining documents. Markdown is always the
drafting medium. The final form may be markdown itself, or the markdown may be
exported to another format (Google Doc, Confluence, etc.) later.

Scribe is self-contained. It may be invoked directly or handed off to by another
workflow — it has no awareness of either case.

---

## Starting a Session

**Always begin with a discussion.** Never start writing before the following is
settled (or consciously deferred):

- **What is the document?** Topic, purpose, audience.
- **Target format.** Markdown-final, Google Doc, Confluence, README, blog post,
  etc. May be unknown — that's fine, defer and revisit later.
- **Starting posture.** Do we have a structure to work from, or are we
  freewriting? If freewriting, structure emerges from content — don't force it
  early.
- **File location.** Where does the working `.md` file live? Confirm or create
  it before drafting begins.

If the user drops in without context, ask for these. If context is already
established (e.g. a task was handed off), confirm the key points and proceed.

---

## Pi's Role During Drafting

Pi is both a brainstorm partner and a high-level orchestrator. These two modes
often alternate within the same session.

**As a brainstorm partner:** engage actively with the user's ideas — ask
questions, push back, surface connections, help develop half-formed thoughts.
The user may dump a raw stream of consciousness into the file or chat; pi's job
is to receive that without judgment and help make sense of it.

**As an orchestrator:** shape structure, propose outlines, reorganize sections,
and edit the file directly. For simple documents pi may handle most of the
writing. For complex ones pi organizes and the user or aider handles the
detailed prose.

Pi reads the current file state as needed to stay in sync. There is no fixed
ratio — adapt to what the document and the user need.

---

## Drafting Phases

### 1. Structure

Discuss and agree on a rough outline before writing prose. For freewriting sessions, skip this entirely — the user may dump a raw stream
of consciousness into the file or chat and structure is imposed afterward. Pi
reads the dump, identifies themes and natural groupings, and proposes a
reorganization for the user to react to.

### 2. Draft

Pi writes or edits the markdown file directly. The user decides if and when to
hand off to aider.

### 3. Refine

Review the full document together. Identify gaps, weak sections, or structural
issues. Iterate — back to draft phase as needed.

### 4. Finalize format

If the target format is markdown: done. If export is needed (Google Doc,
Confluence, etc.), that is a separate step handled outside scribe.

---

## Aider Handoff

When the user decides to hand off to aider, launch it on the working document.

### Launching aider

Before launching, write context and a commands file to `.pi/tmp.local/`:

```bash
cat > ~/.pi/tmp.local/scribe-prompt.txt << 'EOF'
[context about the document, goals, current state]
EOF

cat > ~/.pi/tmp.local/scribe-commands.txt << 'EOF'
/read /full/path/to/document.md
/read ~/.pi/tmp.local/scribe-prompt.txt
EOF
```

Then launch:

```bash
# Basic
tmux new-window -t SESSION -n aider "bash --init-file <(echo 'source ~/.bash_aliases') -i" \; \
  send-keys -t SESSION "cd /path/to/workdir && aider --load ~/.pi/tmp.local/scribe-commands.txt /path/to/document.md" Enter

# With watch mode
tmux new-window -t SESSION -n aider "bash --init-file <(echo 'source ~/.bash_aliases') -i" \; \
  send-keys -t SESSION "cd /path/to/workdir && aider --watch-files --load ~/.pi/tmp.local/scribe-commands.txt /path/to/document.md" Enter
```

The `aider` alias sets `--chat-mode ask` (read-only) by default. To have aider
write to the file, switch to `/code` inside the session manually.

### Watch mode annotation syntax

In the markdown file, add a line comment with `AI`, `AI!`, or `AI?`:

```markdown
# AI: rewrite this paragraph, it's too passive
# AI! expand this section with two concrete examples
# AI? is this the right place for this point?
```

`AI!` triggers immediately. `AI?` asks a question without making changes.
Watch mode is optional — use it when inline annotation is more natural than
chat.

### Returning to pi

When done in aider, return to the pi session. Pi then:

1. Spawns the `aider-summarizer` subagent with the full path to
   `.aider.chat.history.md` to summarize what was discussed and decided.
2. Reads the current document state.
3. Continues from where things left off.

The summary captures discussion context that the document alone doesn't reflect.

---

## Non-Goals

- **No export mechanics.** Google Docs, Confluence, and other export targets are
  handled outside scribe when the time comes.
- **No git workflow.** Scribe does not manage commits or branches.
- **No awareness of other skills.** Scribe does not reference or invoke
  commander, recon, or sortie.
