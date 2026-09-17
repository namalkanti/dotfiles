# Task: Replace the ask and shell-command aliases with a polished Babashka frontend over Pi

**Status**: Draft — Ready for execution

## Context

The dotfiles currently define two shell functions in `.bash_aliases`:

- `ask` invokes Pi in one-shot print mode with no session or tools, a concise-answer system prompt, and `openrouter/deepseek/deepseek-v4-flash-0731`.
- `cmd` invokes Pi similarly with a command-only prompt, prints the generated command, and copies it to the X clipboard with `xclip`.

They are functional, but `ask` lacks the readable, polished terminal presentation previously provided by AIChat. AIChat's relevant behavior is smaller than the rest of that project: it applies syntax coloring to model-produced Markdown, wraps it to the terminal, and smoothly displays streamed output. Its renderer does not substantially transform Markdown into a custom report.

AIChat's streaming implementation divides output into committed complete lines and a mutable unfinished line. It repeatedly clears and redraws the mutable line so tokens can appear immediately while remaining highlighted and correctly wrapped. That cursor-management layer is where much of the complexity lies.

This iteration deliberately adopts a simpler option: line-buffered streaming. Complete lines are highlighted and displayed as they arrive; the unfinished line remains buffered until a newline or response completion. This should retain most of AIChat's readability without raw-terminal redraw logic. If the burst-per-line ergonomics prove unsatisfactory, a later recon can evaluate a Rust implementation with AIChat-style mutable-tail redraw.

Local environment discovered during recon:

- Dotfiles repository: `/home/neji49/.config/dotfiles`
- Current aliases: `/home/neji49/.config/dotfiles/.bash_aliases`
- `~/.bash_aliases` and `~/.bashrc` are symlinks into that repository.
- Zsh also sources `~/.bash_aliases`.
- Pi 0.85.1 is installed at `/usr/bin/pi`.
- `bat` 0.26.1 is installed at `/usr/bin/bat` and supports Markdown syntax.
- `xclip` is installed at `/usr/bin/xclip`; `wl-copy` is not installed.
- Babashka is not currently installed and must be treated as an explicit prerequisite.
- A persistent `bat --language markdown --plain --color=always --paging=never` process was verified to emit highlighted lines before stdin reaches EOF, so it can support line-buffered streaming without one process per line.
- The repository already contains an unrelated untracked plan; execution must not modify or remove unrelated worktree changes.

This work is intentionally non-urgent and should favor clarity and easy modification for someone ramping up on Clojure. Keep the Babashka implementation idiomatic but small, with names and structure that make prompts, presentation, and process behavior easy to tune.

## Design Decisions

- **Decision**: Implement a Babashka script rather than Rust for this iteration. The smaller script and rapid edit-run cycle are more valuable than exact mutable-tail redraw.
- **Decision**: Keep Pi as the LLM backend. Reuse its model catalog, authentication, provider support, and one-shot behavior rather than adding direct provider clients.
- **Decision**: Use Pi JSON event-stream mode to receive `text_delta` events and control presentation.
- **Decision**: Use one persistent `bat` child to color Markdown lines. AIChat itself uses `syntect` with syntax assets derived from `bat`, making this close to the desired visual treatment without embedding a renderer.
- **Decision**: Implement line-buffered streaming for `ask`. Exact AIChat-style cursor redraw is out of scope.
- **Decision**: Buffer `bash-gen` completely and expose/copy output only after successful completion; partially generated commands are not useful.
- **Decision**: Introduce `bash-gen` while retaining `cmd` as a compatibility wrapper.
- **Decision**: Render color only for an interactive TTY. Pipes and redirection receive raw Markdown, and `NO_COLOR` disables color.
- **Decision**: Do not execute generated commands. Generation, display, and clipboard copy are the complete scope.
- **Decision**: Babashka installation is a documented prerequisite; the utility must not install system packages itself.

## Key Sources

- `/home/neji49/.config/dotfiles/.bash_aliases` — Current `ask` and `cmd` functions, prompts, model choice, and clipboard behavior.
- `/home/neji49/.config/dotfiles/.zshrc` — Confirms the shared aliases file is sourced by Zsh as well as being used from Bash.
- `/usr/lib/pi-coding-agent/docs/json.md` — Authoritative Pi JSONL event format. `message_update` events carry delta-only `assistantMessageEvent` objects; `message_end` carries the final authoritative message.
- `/usr/lib/pi-coding-agent/README.md` — Pi CLI flags and one-shot/RPC integration behavior.
- `https://github.com/sigoden/aichat/blob/main/src/render/markdown.rs` — AIChat's Markdown coloring, fenced-code state, and wrapping implementation.
- `https://github.com/sigoden/aichat/blob/main/src/render/stream.rs` — AIChat's mutable-tail buffering and terminal redraw implementation; useful for understanding what this iteration intentionally omits.
- `https://github.com/sigoden/aichat/blob/main/src/render/mod.rs` — AIChat's TTY/highlight selection and raw-output fallback.
- `https://github.com/babashka/cli` — Babashka subcommand and option parsing.
- `https://github.com/babashka/process` — Child-process lifecycle and streaming I/O APIs.

## Proposed Steps

1. **Establish executable placement and command surface** (INVESTIGATION)
   - Goal: Confirm where the tracked script belongs and how both supported shells should invoke it without creating unnecessary installation machinery.
   - Status (Step 1): TODO
   - Approach:
     - Inspect existing dotfile conventions and PATH setup before choosing the script path.
     - Prefer a tracked location inside `/home/neji49/.config/dotfiles` and explicit invocation from `.bash_aliases` unless an existing script-link convention is found.
     - Preserve the user-facing `ask` and `bash-gen` names and retain `cmd` as a compatibility wrapper.
     - Confirm the wrapper syntax is valid when `.bash_aliases` is sourced by both Bash and Zsh.
     - Record Babashka installation as a prerequisite; do not add package installation side effects.
   - Sources:
     - `/home/neji49/.config/dotfiles/.bash_aliases`
     - `/home/neji49/.config/dotfiles/.bashrc`
     - `/home/neji49/.config/dotfiles/.zshrc`

2. **Verify Pi and renderer streaming contracts** (INVESTIGATION)
   - Goal: Replace assumptions about external-process behavior with observed contracts before implementation.
   - Status (Step 2): TODO
   - Approach:
     - Run a minimal one-shot Pi request with `--mode json --no-session --no-tools` and inspect `text_delta`, `message_end`, error, stderr, cancellation, and exit-status behavior.
     - Determine how to extract only assistant text deltas while ignoring lifecycle, thinking, usage, and unrelated event records.
     - Confirm whether `message_end` should be used to validate or recover the authoritative final text without duplicating streamed text.
     - Reconfirm that one persistent `bat --language markdown --plain --color=always --paging=never` child flushes each complete line in the target WezTerm/tmux environment.
     - Determine whether additional `bat` flags are required for predictable wrapping or decoration suppression.
     - Keep Pi diagnostics on stderr so they cannot contaminate rendered stdout or command capture.
   - Sources:
     - `/usr/lib/pi-coding-agent/docs/json.md`
     - `/usr/lib/pi-coding-agent/README.md`
     - `bat --help`

3. **Implement the Babashka CLI and shared Pi runner** (EXECUTION)
   - Goal: Add a small, readable utility that owns argument handling and the common Pi child-process lifecycle.
   - Status (Step 3): TODO
   - Approach:
     - Add one executable Babashka script with `ask` and `bash-gen` subcommands.
     - Use `babashka.cli` for explicit dispatch and help rather than hand-parsing options.
     - Centralize named configuration for the model, reasoning level, common Pi flags, and system prompts so behavior is easy to adjust.
     - Invoke Pi with an argument vector, never by concatenating a shell command; preserve user arguments without shell re-parsing.
     - Support piped stdin consistently with Pi's one-shot semantics.
     - Decode stdout as JSONL incrementally and route stderr separately.
     - Propagate meaningful nonzero statuses and clear diagnostics.
     - On Ctrl-C, exceptions, or downstream renderer failure, terminate and wait for all child processes. Explicitly verify that no Pi, `bat`, or clipboard process can be orphaned.

4. **Implement line-buffered Markdown presentation for ask** (EXECUTION)
   - Goal: Produce readable AIChat-like colored Markdown with progressive complete-line output and modest implementation complexity.
   - Status (Step 4): TODO
   - Approach:
     - Show a lightweight spinner on stderr only while waiting for the first assistant text delta.
     - Accumulate arbitrary `text_delta` fragments into a pending string.
     - Split and forward only newline-complete text to one persistent `bat` process.
     - At successful completion, forward the final incomplete line, close renderer stdin, and wait for renderer completion.
     - Preserve model-generated Markdown exactly apart from terminal presentation and any necessary tab normalization confirmed during Step 2.
     - Enable `bat` coloring only when stdout is a TTY and `NO_COLOR` is absent.
     - For pipes, redirection, or `NO_COLOR`, bypass `bat` and emit raw Markdown while retaining line-buffered stream handling.
     - Keep progress UI and diagnostics on stderr so stdout remains composable.
     - Do not implement raw terminal mode, cursor-position queries, clearing, repainting, or mutable-tail display.

5. **Implement safe bash-gen output and clipboard handling** (EXECUTION)
   - Goal: Generate one complete Bash command, print it cleanly, and copy it only when generation succeeds.
   - Status (Step 5): TODO
   - Approach:
     - Use the existing command-only intent: request exactly one directly executable Bash command with no explanation or Markdown.
     - Buffer generated text rather than exposing partial command fragments.
     - Use Pi's final authoritative assistant message to validate assembled output if Step 2 shows this is necessary.
     - Normalize surrounding whitespace only; do not parse, rewrite, lint, repair, or execute the command.
     - Print the command to stdout after successful Pi completion.
     - Copy the exact printed command through `xclip -selection clipboard` only after generation succeeds.
     - Report clipboard failure on stderr and return a documented nonzero status rather than silently claiming full success.
     - Keep clipboard selection behind a small named function so Wayland or other clipboard backends can be substituted later.

6. **Replace shell functions with thin wrappers** (EXECUTION)
   - Goal: Make shell configuration delegate all substantive behavior to the Babashka utility.
   - Status (Step 6): TODO
   - Approach:
     - Update `/home/neji49/.config/dotfiles/.bash_aliases` so `ask` and `bash-gen` invoke the script and forward arguments unchanged.
     - Keep `cmd` as a compatibility wrapper for `bash-gen`.
     - Remove duplicated Pi flags, prompts, model configuration, and clipboard logic from shell code.
     - Verify sourcing the updated file in both Bash and Zsh does not produce syntax errors.

7. **Add deterministic tests and perform terminal smoke tests** (EXECUTION)
   - Goal: Verify stream assembly, process cleanup, output-channel discipline, and user-visible ergonomics without relying exclusively on paid/live model calls.
   - Status (Step 7): TODO
   - Approach:
     - Add a mock Pi executable or injectable Pi path that emits deterministic JSONL fixtures.
     - Cover deltas fragmented inside words, multiple lines in one delta, blank lines, Unicode, and a response without a trailing newline.
     - Cover malformed JSON, Pi nonzero exit, missing completion, `bat` failure, clipboard failure, and interruption.
     - Verify colored TTY output and raw piped output independently. Use a pseudo-terminal test where practical; otherwise document the manual TTY assertion.
     - Verify stdout contains only answer/command content and stderr contains spinner and diagnostics.
     - Verify `bash-gen` never copies or prints partial output after Pi failure.
     - Run manual smoke tests with real Pi in plain WezTerm and tmux, judging line-burst latency, Markdown readability, wrapping, cancellation, and clipboard contents.
     - Re-read each non-trivial function after tests, tracing all branches and explicitly checking child cleanup and exception propagation.

8. **Document usage, prerequisites, and tuning points** (EXECUTION)
   - Goal: Leave enough local documentation that the utility can be resumed and modified later without rediscovering its design.
   - Status (Step 8): TODO
   - Approach:
     - Document Babashka, Pi, `bat`, and `xclip` prerequisites and provide invocation examples for `ask`, `bash-gen`, and `cmd`.
     - Explain that `ask` displays complete lines progressively, so long unfinished paragraphs may appear in bursts.
     - Identify the intentionally easy tuning points: model, prompts, spinner, `bat` theme/options, wrapping, aliases, and clipboard backend.
     - Record clean stdout/non-TTY behavior for scripting.
     - Note that exact AIChat-style mutable-tail redraw is intentionally deferred. If line buffering feels sluggish after real use, start a new recon for a Rust terminal frontend rather than growing cursor-management complexity into this script by default.

## Notes

- Do not optimize for exact visual parity before trying the line-buffered version in normal use. The purpose of this iteration is to test whether most of AIChat's perceived polish comes from Markdown coloring and clean output rather than mutable-tail redraw.
- Avoid teaching Clojure through excessive comments. Prefer small functions, descriptive names, named constants, and a short architecture note where process ownership is non-obvious.
- A persistent `bat` process is important. Spawning one formatter per line would add needless overhead and complicate failure handling.
- Pi's JSON mode emits delta-only `message_update` events and a final authoritative `message_end`; implementation must not assume each delta is a complete line or a complete JSON response.
- Non-TTY output must remain raw and stable so commands such as `ask ... | less`, redirection, and command substitution are usable.
- The current requested name is `bash-gen`, while the existing implementation is named `cmd`; preserving `cmd` avoids breaking muscle memory during evaluation.
- Since this task may be picked up much later, recheck installed versions and the current Pi JSON documentation before execution.
