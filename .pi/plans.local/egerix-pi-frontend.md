# Task: Build Egerix, a polished Rust frontend for ephemeral ask and bash-gen conversations over Pi

**Status**: Draft — Ready for execution

## Context

The dotfiles currently define two simple shell functions in `.bash_aliases`:

- `ask` invokes Pi in one-shot print mode with no normal session or tools, a concise-answer system prompt, and `openrouter/deepseek/deepseek-v4-flash-0731`.
- `cmd` invokes Pi similarly with a command-only prompt, prints the generated command, and copies it to the X clipboard with `xclip`.

The existing Bash implementation is already sufficient for unformatted one-shot use. The purpose of this work is therefore not merely to replace Bash: it is to recover the polished terminal presentation previously provided by AIChat while retaining Pi as the model/provider backend. The important behavior is seamless progressive output, Markdown and fenced-code coloring, terminal-width-aware wrapping, and correct mutable-tail redraw as tokens arrive.

A prior version of this plan proposed Babashka plus a persistent `bat` process. That approach would provide basic Markdown syntax coloring, but Babashka would only orchestrate external processes; `bat` would not reproduce AIChat's wrapping and mutable unfinished-line rendering. It would also add `bb` and `bat` as runtime dependencies while still omitting the feature that justifies this utility. This plan therefore uses Rust from the beginning and treats AIChat's renderer as the behavioral reference.

Egerix should also support very short follow-up exchanges. A normal `ask` or `bash-gen` invocation creates a fresh ephemeral conversation for the current terminal/PTY. A subsequent invocation with `--continue` resumes it, and further continued calls extend it. The chain is shared across `ask` and `bash-gen`, intentionally transient, and isolated from normal Pi sessions. It exists for one or two immediate follow-ups, not durable chat management. State belongs in a private per-user directory under `/tmp`, scoped by controlling PTY, and may disappear at reboot.

The temporary conversation should be readable and self-contained. If an exchange unexpectedly becomes useful, the user can start ordinary Pi and reference the transcript file as context. There is no dedicated promote, fork, import, retention, browser, or recovery feature.

Local environment discovered during the earlier recon:

- Dotfiles repository: `/home/neji49/.config/dotfiles`
- Current aliases: `/home/neji49/.config/dotfiles/.bash_aliases`
- `~/.bash_aliases` and `~/.bashrc` are symlinks into that repository.
- Zsh also sources `~/.bash_aliases`.
- Pi 0.85.1 was installed at `/usr/bin/pi` when recon was performed; recheck before implementation.
- `xclip` is installed at `/usr/bin/xclip`; `wl-copy` was not installed.
- The repository contained an unrelated untracked plan during earlier recon; execution must not modify or remove unrelated worktree changes.

## Name and Etymology

`Egerix` is derived from **Egeria**, the Roman nymph and trusted counselor to King Numa Pompilius. The reference fits the tool's role as a lightweight private advisor: available for a quick question, command, or immediate follow-up rather than a durable working session.

The modified ending comes from a personal naming pattern. The ix is a random suffix used in aliases for uniqueness. `Egerix` applies the same idea to Egeria, producing a more distinctive project name while retaining the advisor reference.

## Design Decisions

- **Decision**: Name the project, Rust package, and executable `egerix`. Keep `ask`, `bash-gen`, and `cmd` as convenient shell wrappers around Egerix.
- **Decision**: Implement a compiled Rust frontend. Rendering quality and immediate mutable-tail output are the reason to build this utility; a Babashka wrapper around `bat` would compromise those requirements.
- **Decision**: Keep Pi as the LLM backend. Reuse its model catalog, authentication, provider support, and one-shot integration rather than adding direct provider clients.
- **Decision**: Treat AIChat as the rendering reference. Review and pin the relevant source revision before implementation rather than relying on memory or a moving `main` branch.
- **Decision**: Embed highlighting and terminal behavior in the Rust executable. Do not require Babashka or `bat` at runtime.
- **Decision**: Use Pi JSON event-stream mode to receive text deltas and control presentation.
- **Decision**: Implement committed-lines plus mutable-tail redraw for interactive `ask`, including width-aware wrapping and fenced-code highlighting.
- **Decision**: Render terminal styling only when stdout is an interactive TTY and `NO_COLOR` is absent. Pipes and redirection receive exact raw model text without cursor control.
- **Decision**: Buffer `bash-gen` completely and expose/copy output only after successful completion; partially generated commands are not useful.
- **Decision**: Introduce `bash-gen` while retaining `cmd` as a compatibility wrapper.
- **Decision**: Do not execute generated commands. Generation, display, and clipboard copy are the complete command-mode scope.
- **Decision**: Use one shared ephemeral continuation chain per terminal/PTY for both `ask` and `bash-gen`.
- **Decision**: A normal invocation starts a fresh chain; only `--continue` reuses the prior chain. Successful continuation atomically extends it, while failure or cancellation preserves the last complete transcript.
- **Decision**: Store continuation state under a private per-user directory in `/tmp`, not Pi's normal session storage. Reboot loss is desirable, and stale-file cleanup should remain minimal.
- **Decision**: Keep the temporary transcript readable enough to reference from ordinary Pi, but provide no intentional promotion/import workflow.
- **Decision**: Continue to use `xclip` initially, behind a small isolated clipboard interface so another backend can replace it later.

## Key Sources

- `/home/neji49/.config/dotfiles/.bash_aliases` — Current `ask` and `cmd` behavior, prompts, model choice, Pi flags, and clipboard handling.
- `/home/neji49/.config/dotfiles/.bashrc` — Bash PATH and shell configuration conventions.
- `/home/neji49/.config/dotfiles/.zshrc` — Confirms that Zsh sources the shared aliases file.
- `/usr/lib/pi-coding-agent/README.md` — Pi CLI flags, one-shot behavior, and session/integration entry points. Re-read completely and follow relevant references before implementation.
- `/usr/lib/pi-coding-agent/docs/json.md` — Authoritative Pi JSONL event format. Re-read completely before implementing the event decoder.
- `https://github.com/sigoden/aichat/blob/main/src/render/markdown.rs` — AIChat Markdown/fenced-code highlighting, syntax selection, and wrapping behavior. Pin the reviewed commit.
- `https://github.com/sigoden/aichat/blob/main/src/render/stream.rs` — AIChat committed-line/mutable-tail buffering, raw mode, cursor movement, scrolling, clearing, display-width calculation, and redraw behavior. Pin the reviewed commit.
- `https://github.com/sigoden/aichat/blob/main/src/render/mod.rs` — AIChat selection between interactive highlighting and raw output. Pin the reviewed commit.
- `https://github.com/sigoden/aichat` — Broader source, tests, dependency choices, and license/attribution requirements.
- `https://docs.rs/clap/latest/clap/` — Rust command-line parsing reference.
- `https://docs.rs/crossterm/latest/crossterm/` — Terminal detection, raw mode, cursor, events, and cleanup contracts.
- `https://docs.rs/syntect/latest/syntect/` — Markdown and fenced-code syntax highlighting facilities.
- `https://docs.rs/textwrap/latest/textwrap/` — Width-aware wrapping behavior and indentation options.
- `https://docs.rs/unicode-width/latest/unicode_width/` — Display-column width calculations for terminal text.

## Proposed Steps

1. **Confirm executable placement and shell integration** (INVESTIGATION)
   - Goal: Choose a repository layout, build/install path, and shell surface that fit the existing dotfiles without unnecessary deployment machinery.
   - Status (Step 1): TODO
   - Approach:
     - Inspect current dotfile conventions, PATH setup, tracked scripts/binaries, and any existing Rust build/install patterns.
     - Choose where the Rust crate belongs and how its binary becomes available to both Bash and Zsh.
     - Preserve the user-facing `ask` and `bash-gen` names and retain `cmd` as a compatibility wrapper.
     - Confirm wrapper syntax and argument forwarding work when `.bash_aliases` is sourced by both shells.
     - Recheck installed Pi, Rust, Cargo, and clipboard-tool versions before implementation.
   - Sources:
     - `/home/neji49/.config/dotfiles/.bash_aliases`
     - `/home/neji49/.config/dotfiles/.bashrc`
     - `/home/neji49/.config/dotfiles/.zshrc`
     - Existing tracked scripts and build files under `/home/neji49/.config/dotfiles`

2. **Study and pin AIChat's rendering behavior** (INVESTIGATION)
   - Goal: Turn “AIChat-like” into an explicit behavioral reference before selecting APIs or writing terminal code.
   - Status (Step 2): TODO
   - Approach:
     - Record the exact AIChat commit reviewed so implementation and attribution do not depend on a moving `main` branch.
     - Read the Markdown renderer, stream renderer, render-mode selection, spinner, abort handling, terminal helpers, and relevant tests/call sites.
     - Trace how AIChat separates committed complete lines from the mutable unfinished tail and how it redraws only the mutable region.
     - Document fenced-code state, syntax selection, theme handling, wrapping options, indentation behavior, code-wrap policy, ANSI/display width, exact-column edge cases, scrolling, terminal resize behavior, tab normalization, and final-newline behavior.
     - Identify which ideas should be reproduced and which are coupled to AIChat's provider or application architecture and should be omitted.
     - Inspect AIChat's license and dependency licenses. If code is directly adapted rather than independently reimplemented from behavior, carry the required copyright notices and attribution into the crate.
   - Sources:
     - `https://github.com/sigoden/aichat/blob/main/src/render/markdown.rs`
     - `https://github.com/sigoden/aichat/blob/main/src/render/stream.rs`
     - `https://github.com/sigoden/aichat/blob/main/src/render/mod.rs`
     - `https://github.com/sigoden/aichat`

3. **Verify Pi JSON streaming and child-process contracts** (INVESTIGATION)
   - Goal: Replace assumptions about the backend with observed behavior before implementing transport and cleanup.
   - Status (Step 3): TODO
   - Approach:
     - Re-read the installed Pi README and JSON documentation completely, following relevant references for one-shot and session behavior.
     - Run minimal requests with the intended JSON, no-session, and no-tools flags.
     - Capture representative lifecycle, `text_delta`, final message, thinking, usage, error, stderr, cancellation, and nonzero-exit behavior.
     - Determine how the final authoritative assistant message relates to assembled deltas and whether it is needed for validation or recovery without duplicating output.
     - Confirm how positional arguments and piped stdin compose in one-shot mode.
     - Determine signal and pipe behavior when the frontend exits, the renderer fails, or the user presses Ctrl-C.
     - Define the ownership, termination, wait, and stderr-forwarding contract for every child process.
   - Sources:
     - `/usr/lib/pi-coding-agent/README.md`
     - `/usr/lib/pi-coding-agent/docs/json.md`
     - Installed `pi --help`

4. **Determine isolated ephemeral continuation mechanics** (INVESTIGATION)
   - Goal: Define a short-lived per-PTY continuation format that cannot interfere with ordinary Pi sessions.
   - Status (Step 4): TODO
   - Approach:
     - Check whether Pi can consume an explicitly located temporary session/transcript without registering it in normal session history. Do not use native session persistence if it touches Pi's normal session directory/index or makes the transcript opaque.
     - Prefer a frontend-owned readable transcript under a mode-`0700` per-user directory in `/tmp`, with files created using restrictive permissions.
     - Determine the minimum structured data needed to reconstruct user/assistant turns faithfully while keeping the saved artifact self-contained and convenient to reference from an ordinary Pi invocation.
     - Keep renderer state, transient progress, and process metadata out of the transcript.
     - Derive a stable, sanitized or hashed state key from the controlling terminal/PTY so separate terminal windows and tmux panes do not share chains. Do not expose raw device paths in unsafe filenames.
     - Define behavior when no controlling TTY exists. Avoid silently merging unrelated redirected invocations into one chain; either reject `--continue` clearly or require an explicit safe fallback identified during investigation.
     - Define fresh-call replacement, successful continuation, missing prior state, malformed state, atomic commit, same-PTY locking, concurrent invocations, and rollback after failure/cancellation.
     - Use a single chain across `ask` and `bash-gen`. Determine how each invocation's mode-specific instruction is represented so changing modes does not corrupt prior turns or accidentally make the command-only instruction permanent.
     - Keep stale cleanup deliberately small: reboot loss is expected, and optional age-based removal is sufficient. Do not build retention, browsing, recovery, promotion, or import features.
     - Confirm the transcript path can be discovered or documented well enough to reference manually from normal Pi when desired, without adding a dedicated command for that handoff.
   - Sources:
     - Pi documentation and observed behavior from Step 3
     - Linux controlling-terminal and `/tmp` ownership/permission behavior

5. **Scaffold the Rust executable and internal boundaries** (EXECUTION)
   - Goal: Create a small crate whose structure makes transport, history, rendering, and command behavior independently testable.
   - Status (Step 5): TODO
   - Approach:
     - Add the `egerix` Rust crate and executable with `ask` and `bash-gen` subcommands.
     - Use `clap` for explicit argument parsing and help, including `--continue` on both subcommands.
     - Use `serde_json` for Pi events and select the smallest suitable terminal stack after Steps 2–3, likely including `crossterm`, `syntect`, `textwrap`, and `unicode-width`.
     - Centralize named configuration for the model, reasoning level, common Pi flags, and mode-specific system instructions.
     - Keep modules/boundaries minimal but separate Pi transport, ephemeral transcript handling, interactive rendering, and clipboard behavior sufficiently for deterministic tests.
     - Invoke child programs with argument vectors, never concatenated shell commands.
     - Add required license notices and source attribution identified in Step 2.

6. **Implement Pi event streaming and lifecycle management** (EXECUTION)
   - Goal: Provide a reliable backend stream that preserves output-channel discipline and cannot orphan children.
   - Status (Step 6): TODO
   - Approach:
     - Spawn Pi with explicit stdin/stdout/stderr ownership and incrementally decode JSONL from stdout.
     - Extract only assistant text deltas and authoritative completion while ignoring or separately handling lifecycle, thinking, usage, and unrelated records.
     - Preserve user arguments and piped input without shell re-parsing.
     - Forward or summarize Pi diagnostics on stderr so they cannot contaminate rendered answers, command capture, or transcript content.
     - Propagate meaningful nonzero statuses and distinguish backend, parse, interruption, and presentation failures where useful.
     - On Ctrl-C, broken pipes, malformed events, exceptions, or downstream failure, terminate and wait for every owned child.
     - Prefer synchronous I/O plus focused threads/polling unless async measurably simplifies simultaneous stdout, stderr, signal, and terminal handling.
     - Re-read the actual selected process/signal APIs before relying on cleanup semantics.

7. **Implement ephemeral per-PTY continuation** (EXECUTION)
   - Goal: Support one or two explicit follow-ups without creating durable sessions or touching normal Pi history.
   - Status (Step 7): TODO
   - Approach:
     - Resolve the controlling PTY and map it to a private temporary transcript path using the contract from Step 4.
     - A normal `ask` or `bash-gen` invocation starts a fresh chain and replaces that PTY's previous complete chain only after the new call succeeds.
     - `--continue` loads the previous complete chain, submits the new turn with the selected mode's current instruction, and atomically commits the extended chain after successful completion.
     - Share one chain between `ask` and `bash-gen`, preserving explicit user/assistant turn boundaries and mode metadata needed to reconstruct intent.
     - Lock same-PTY updates so concurrent calls cannot interleave or silently lose turns.
     - Preserve the previous valid transcript on Pi failure, cancellation, malformed output, rendering failure, clipboard failure where appropriate, or atomic-write failure.
     - Produce a clear diagnostic when `--continue` has no usable prior transcript.
     - Keep the transcript readable and self-contained enough to pass to normal Pi as file context, but add no promote/fork/import subcommand.
     - Ensure all state remains outside Pi's normal session storage and that no ordinary Pi session record is created by the frontend.

8. **Implement AIChat-like interactive presentation for ask** (EXECUTION)
   - Goal: Display model output immediately with stable Markdown styling, wrapping, and mutable-tail redraw.
   - Status (Step 8): TODO
   - Approach:
     - Maintain committed complete lines separately from the mutable unfinished tail.
     - Coalesce deltas only enough to avoid pathological redraw frequency; do not wait for a newline before showing text.
     - Track Markdown fenced-code state and use the declared or inferred language for code highlighting where practical.
     - Highlight ordinary Markdown and code using embedded `syntect` syntax data/theme configuration selected during Step 2.
     - Wrap prose to the current terminal width while preserving indentation; leave code unwrapped by default unless the reference behavior and testing justify another choice.
     - Calculate occupied rows with ANSI-aware Unicode display widths and handle tabs, blank lines, combining/wide characters, exact-width lines, and tails that themselves wrap.
     - Safely clear and redraw only the mutable region, accounting for cursor position, scrolling near the bottom of the screen, terminal resize, WezTerm, and tmux.
     - Show a lightweight spinner on stderr only while waiting for the first assistant text delta and remove it cleanly before output.
     - Use terminal guards so raw mode, cursor visibility, and other modified terminal state are restored on success, error, panic, Ctrl-C, and broken pipes.
     - When stdout is not a TTY or `NO_COLOR` is present, bypass highlighting and cursor manipulation and emit exact raw model text progressively.
     - Do not let visual normalization alter the text stored in the transcript or emitted through raw mode.

9. **Implement complete-command handling for bash-gen** (EXECUTION)
   - Goal: Generate one complete Bash command, print it cleanly, and copy it only when generation succeeds.
   - Status (Step 9): TODO
   - Approach:
     - Use the existing command-only intent: request exactly one directly executable Bash command with no explanation or Markdown.
     - Buffer generated text rather than exposing partial command fragments.
     - Validate assembled deltas against Pi's final authoritative assistant message if Step 3 shows this is necessary.
     - Normalize surrounding whitespace only; do not parse, rewrite, lint, repair, or execute the command.
     - Print the command to stdout only after successful Pi completion.
     - Copy the exact printed command through `xclip -selection clipboard` only after generation succeeds.
     - Keep clipboard selection behind a named interface so Wayland or an embedded backend can replace it later.
     - Define clipboard failure semantics explicitly. Do not claim complete success silently; ensure transcript commit behavior matches the Step 7 contract and does not discard a valid generated exchange unnecessarily.
     - Terminate and wait for the clipboard child on all paths.

10. **Replace shell functions with thin wrappers** (EXECUTION)
   - Goal: Make shell configuration delegate substantive behavior to the Rust utility without adding shell-managed state.
   - Status (Step 10): TODO
   - Approach:
     - Update `/home/neji49/.config/dotfiles/.bash_aliases` so `ask` and `bash-gen` invoke the installed `egerix` executable and forward arguments unchanged.
     - Keep `cmd` as a compatibility wrapper for `bash-gen`.
     - Remove duplicated Pi flags, prompts, model configuration, and clipboard logic from shell code.
     - Do not create or export shell session identifiers; derive continuation scope from the controlling PTY in the executable.
     - Verify sourcing and invocation in both Bash and Zsh.

11. **Add deterministic renderer, process, and continuation tests** (EXECUTION)
   - Goal: Verify terminal redraw, transcript integrity, process cleanup, and output composition without relying on live model calls.
   - Status (Step 11): TODO
   - Approach:
     - Add an injectable Pi path or fake Pi executable that emits deterministic JSONL fixtures and controlled stderr/exit behavior.
     - Cover deltas fragmented inside words and Unicode sequences, multiple lines in one delta, blank lines, long unfinished paragraphs, fenced code, language changes, tabs, combining/wide characters, exact terminal-width boundaries, and responses without trailing newlines.
     - Cover terminal resize, scrolling, spinner removal, raw-mode restoration, malformed JSON, missing completion, Pi nonzero exit, renderer failure, broken pipes, and interruption.
     - Use pseudo-terminals to validate cursor/redraw output and PTY-derived state isolation where practical.
     - Test fresh replacement, multi-step `--continue`, cross-mode continuation, separate terminal/PTY chains, same-PTY locking, missing/malformed state, atomic update, and rollback after failures.
     - Verify non-TTY stdout contains only exact answer content and diagnostics remain on stderr.
     - Verify `bash-gen` never prints, copies, or commits a partial command after backend failure.
     - Verify temporary history never appears in Pi's normal session storage.
     - Assert that no Pi, clipboard, or helper process survives completion, failure, or cancellation.

12. **Perform live comparison and document operation** (EXECUTION)
   - Goal: Validate that the utility delivers the intended polish in the real environment and remains understandable later.
   - Status (Step 12): TODO
   - Approach:
     - Run real Pi smoke tests in plain WezTerm and tmux, including resize, scrolling, cancellation, long paragraphs, Markdown lists, and fenced code.
     - Compare behavior directly with the pinned AIChat reference, judging first-token latency, mutable-tail stability, wrapping, indentation, code highlighting, exact-width lines, and terminal cleanup.
     - Exercise fresh and continued `ask`/`bash-gen` calls across multiple panes and confirm chains remain isolated and transient.
     - Document build/install steps, `ask`, `bash-gen`, `cmd`, `--continue`, raw/non-TTY behavior, transcript location/discovery, reboot-loss semantics, and how to reference a useful transcript manually from normal Pi.
     - Document runtime dependencies (`pi` and initially `xclip`), configurable model/prompts/theme/wrapping, and known differences from AIChat.
     - Re-read every non-trivial process, terminal, and state function as an execution trace. Explicitly verify cleanup guards, child waits, lock release, atomic-write rollback, terminal restoration, and which errors propagate.

## Notes

- The executable is justified by presentation quality. Do not reduce the renderer to line-buffered `bat` output merely to shorten implementation.
- AIChat is a behavioral and source reference, not a dependency on its broader application architecture. Pin the reviewed revision and respect its license.
- `clap` solves command parsing only. The significant work is terminal rendering, process lifecycle, and ephemeral transcript correctness.
- Non-TTY output must remain raw and stable so piping, redirection, and command substitution remain useful.
- The continuation transcript is a convenience buffer, not a session system. Avoid retention policies, listing commands, naming, search, promotion, synchronization, or durable storage.
- A terminal window or tmux pane is the intended isolation boundary. Calls without a controlling TTY must not accidentally share global continuation state.
- Cross-mode continuation is intentional. Keep prior turns intact while applying the current invocation's `ask` or command-only instruction locally; verify the exact Pi mechanism rather than assuming system-prompt replacement semantics.
- A readable temporary transcript enables an informal handoff to normal Pi without adding product surface.
- Generated commands must never be executed by this utility.
- Since execution may happen later, recheck installed versions, current Pi JSON documentation, and current AIChat source before implementation.
