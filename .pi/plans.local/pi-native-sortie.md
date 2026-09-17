# Task: Build a pi-native Sortie workflow with isolated branch context

**Status**: Draft — Ready for execution

## References
- `.pi/notes.local/sortie-skill-2025-07-17.md` — Records the design and validation of the existing aider-based Sortie workflow.
- `.pi/notes.local/model-escalation-workflow-2026-07-15.md` — Confirms native `/tree` branching and branch summaries as an effective context-return mechanism.

## Context
The current `sortie` skill orchestrates an external aider session. It establishes task scope and file roles, generates candidate diffs, writes prompt and command files, launches aider in tmux with watch mode, and later summarizes aider's chat history. Aider is no longer receiving updates at a desirable pace, and only a subset of its behavior is valuable here: isolated task context, curated files, a repository map, and editor-comment watch mode. Aider's Git integration and automatic commits are explicitly out of scope.

Pi's extension API can replace the mechanical handoff without core changes. An extension command can capture the current session leaf, label it with `pi.setLabel()`, persist workflow state with `pi.appendEntry()`, switch models with `pi.setModel()`, and later return through `ctx.navigateTree(checkpointId, { summarize: true })`. Native branch summaries replace aider chat-history files and the separate `aider-summarizer` handoff.

A sortie must not inherit the full parent conversation. While a sortie is active, a `context` event handler will retain Pi's normal system prompt, tools, project context files such as `AGENTS.md`, and loaded skill instructions, but remove conversation messages preceding a persisted sortie context boundary. The skill must therefore construct a self-contained kickoff containing the approved task context. No compaction or inherited-history summary mode will be implemented.

Existing packages can supply two costly pieces initially:

- `vedang/pi-watcher` already implements editor-comment watching, queueing while Pi is busy, loop prevention, and marker cleanup after `agent_settled`. Its parser currently expects suffix operators (`AI!`, `AI?`, `AI.`), while the desired defaults are prefix operators (`!AI`, `?AI`). Source and license must be inspected before choosing an upstream contribution, pinned fork, or maintained local derivative.
- `@sn-kaier/pi-repomap` exposes a programmatic `generateRepomap()` API and implements tree-sitter extraction, definition/reference graph construction, PageRank, selected-file boosting, and token-budgeted rendering. Its strong language support is currently limited primarily to JavaScript/TypeScript, Python, and Markdown; C++, Rust, Go, and Kotlin coverage must be treated as a known limitation.

The migration will be staged. The existing aider workflow will remain available as `sortie-aider` until the pi-native workflow is validated and deliberately cut over. No shared backend abstraction is needed between the temporary fallback and its intended replacement.

## Design Decisions
- **Extension-only implementation**: Do not propose or require changes to pi core.
- **Combined skill and extension package**: The skill owns discussion, judgment, candidate diffs, and approval; TypeScript owns deterministic session, model, context, and navigation mechanics.
- **Fresh context only**: Filter pre-sortie conversation from provider context instead of compacting it or generating a carry-over summary.
- **Self-contained kickoff**: The skill must explicitly package all information the sortie needs; it cannot depend on hidden parent conversation.
- **Same-session tree branch**: Use a labeled checkpoint and native tree navigation so Pi can automatically summarize the abandoned work back at the starting point.
- **Configurable sortie model**: Support a default provider/model and optional thinking level, plus a per-sortie override. Validate model availability and authentication before starting.
- **Prompt-level file roles**: Editable and reference file distinctions may guide prompting but will not be enforced by tool-call guards.
- **Normal Pi file access**: Curated files are named and boosted in the kickoff/repo map, then read with ordinary Pi tools. Full file contents are not reinjected on every model request.
- **Independent watcher**: Preserve the watcher as a generally useful standalone extension rather than coupling its lifecycle to Sortie.
- **Replaceable repo-map provider**: Put the initial external map implementation behind a small local interface so it can later be extended or replaced.
- **One active sortie per session initially**: Reject nested or duplicate starts instead of designing a stack of active checkpoints.
- **No commits or Git automation**: Git state management is not part of this replacement.

## Key Sources
- `/home/neji49/.pi/agent/skills/sortie/SKILL.md` — Current aider-based workflow, approval gates, launch behavior, and hand-back semantics.
- `/home/neji49/.pi/agent/skills/sortie/references/prompt-templates.md` — Current interactive and exploration kickoff structures.
- `/usr/lib/pi-coding-agent/docs/extensions.md` — Extension events, commands, labels, model control, persistence, context filtering, and tree-navigation APIs.
- `/usr/lib/pi-coding-agent/docs/session-format.md` — Session tree, branch summaries, labels, custom entries, and `SessionManager` behavior.
- `/usr/lib/pi-coding-agent/docs/sessions.md` — User-facing `/tree` navigation and branch-summary behavior.
- `/usr/lib/pi-coding-agent/examples/extensions/bookmark.ts` — Minimal persistent checkpoint labeling example.
- `/usr/lib/pi-coding-agent/examples/extensions/file-trigger.ts` — Basic watcher lifecycle and message injection example.
- `/usr/lib/pi-coding-agent/examples/extensions/summarize.ts` — Example of extension-driven model invocation and session traversal.
- `https://github.com/vedang/pi-watcher` — Candidate standalone aider-style watch extension.
- `https://github.com/sn-kaier/pi-repomap` — Candidate initial repository-map provider and documented programmatic API.
- `https://github.com/Aider-AI/aider/blob/main/aider/repomap.py` — Apache-2.0 reference implementation for a possible future TypeScript port.
- `https://raw.githubusercontent.com/Aider-AI/aider/main/LICENSE.txt` — License obligations for any future port of aider logic.

## Proposed Steps

1. **Preserve the aider fallback** (EXECUTION)
   - Goal: Keep the validated aider workflow available while the pi-native replacement is developed and trialed.
   - Status (Step 1): TODO
   - Approach: Rename the existing `sortie` skill to `sortie-aider`. Update only names, invocation references, and temporary-file prefixes that would collide with the new package. Preserve the current cold/context-rich entry behavior, candidate-diff generation, explicit approval boundary, prompt templates, tmux launch command, watch flag, history pinning, and return summarization. Verify that both skill names can coexist before changing any behavior.

2. **Validate and select external watcher and repo-map dependencies** (INVESTIGATION)
   - Goal: Establish which existing components can be safely reused and identify their exact integration constraints.
   - Status (Step 2): TODO
   - Approach: Inspect the source, package metadata, API, tests, release state, and licenses of `vedang/pi-watcher` and `@sn-kaier/pi-repomap`. Load them in an isolated Pi configuration rather than altering the normal environment during initial evaluation. For the watcher, exercise `AI!`, `AI?`, context anchors, marker cleanup, repeated saves, loop suppression, multiple markers, and saves while the agent is busy. Determine the smallest maintainable parser/configuration change that supports prefix forms `!AI` and `?AI` while retaining token boundaries and comment-position rules; choose explicitly between an upstream contribution, pinned fork, or local derivative. For the repo map, verify the documented programmatic import, installation/runtime dependency behavior, ignore handling, selected-file boosting, output budgeting, cancellation, and error behavior. Compare useful output on representative Python, TypeScript, C++, and Rust repositories and record unsupported-language degradation.
   - Sources: `https://github.com/vedang/pi-watcher`, `https://github.com/sn-kaier/pi-repomap`, Pi package documentation referenced from `/usr/lib/pi-coding-agent/docs/extensions.md`.

3. **Prove native branch, model, and isolated-context mechanics** (INVESTIGATION)
   - Goal: Confirm the critical Pi APIs and lifecycle behavior before building the full package.
   - Status (Step 3): TODO
   - Approach: Build a disposable extension prototype that captures the current leaf ID, assigns a visible checkpoint label, persists the checkpoint and active state, appends a recognizable sortie context boundary, and filters provider messages before that boundary through the `context` event. Confirm that the system prompt, tools, loaded skills, and project context files remain available while earlier conversation messages do not. Switch to a configured test model and thinking level after the checkpoint, perform several turns and tool calls, then invoke `ctx.navigateTree(checkpointId, { summarize: true, label: ... })`. Verify where the `branch_summary` is attached, that returning disables context filtering, and that the original branch's model/thinking state is restored. Repeat across `/reload` and process resume. Exercise cancelled and failed branch summarization, stale checkpoint IDs, and navigation to sibling branches. Record exact API contracts and failure behavior for implementation.
   - Sources: `/usr/lib/pi-coding-agent/docs/extensions.md`, `/usr/lib/pi-coding-agent/docs/session-format.md`, `/usr/lib/pi-coding-agent/docs/sessions.md`, `/usr/lib/pi-coding-agent/examples/extensions/bookmark.ts`.

4. **Create the combined pi-native Sortie package** (EXECUTION)
   - Goal: Establish a maintainable package boundary for the new skill and deterministic extension logic.
   - Status (Step 4): TODO
   - Approach: Create a package containing the `sortie` skill, its reference material, a TypeScript extension entry point, session-state helpers, context-policy logic, configuration parsing, and a small `RepoMapProvider` interface. Declare and pin the selected repo-map dependency according to the outcome of Step 2. Keep the watcher separately installable and configurable rather than importing it into Sortie. Define typed state and configuration schemas early, but avoid abstractions beyond the active workflow and provider seam.

5. **Implement configuration and the branch state machine** (EXECUTION)
   - Goal: Provide reliable start, inspection, return, and cancellation mechanics that survive extension reload and session resume.
   - Status (Step 5): TODO
   - Approach: Register commands for starting, showing status, returning, and cancelling a sortie. Support configuration for a default provider/model and optional thinking level, with a per-start override. Resolve the model through `ctx.modelRegistry`, verify configured authentication, and reject invalid configuration before appending checkpoint state or switching models. Persist the checkpoint ID, boundary identity, active/cancelled state, selected paths, task metadata, and effective model settings in branch-aware extension entries. Reconstruct state only from the active branch on `session_start`; ensure stale state from abandoned or sibling branches cannot activate filtering. Permit one active sortie per session and produce actionable diagnostics for duplicate starts, missing boundaries, stale checkpoint IDs, and invalid transitions. Treat `ctx.navigateTree()` as the successful return path and define cancellation semantics explicitly without generating a misleading completion summary.

6. **Implement model-aware isolated kickoff context** (EXECUTION)
   - Goal: Start each sortie with an aider-like fresh context assembled from explicitly approved material.
   - Status (Step 6): TODO
   - Approach: After approval, capture and label the checkpoint, activate persisted sortie state, switch to the effective sortie model/thinking level, and establish the context boundary. Generate a token-budgeted repository map rooted at the project and biased toward the selected files. Dispatch one self-contained kickoff containing the goal, necessary background, candidate diffs, selected editable/reference paths as advisory roles, repository map, in-scope/out-of-scope boundaries, and interactive behavior constraints. Register a `context` handler that, only while the matching sortie state is active, removes all conversation messages preceding the boundary and retains the boundary/kickoff plus subsequent messages and tool results. Do not compact parent context and do not repeatedly inject complete file contents. Bound repo-map output and handle provider failure with an explicit user-visible choice to abort or start without a map.

7. **Write the pi-native `sortie` skill** (EXECUTION)
   - Goal: Preserve the successful human/LLM workflow while replacing aider-specific mechanics.
   - Status (Step 7): TODO
   - Approach: Adapt the current skill's cold versus context-rich entry, concrete candidate-diff generation, file selection, scope discipline, and strict explicit-approval gate. Make the skill responsible for extracting all necessary context from the parent conversation and producing a kickoff that stands alone once earlier messages are filtered. Default to the configured sortie model unless the user requests an override. Replace prompt/command file writes, tmux launch, and aider-history summarization with the extension's start and return commands. Preserve the rule that candidate generation and starting the isolated sortie cannot occur in the same turn without explicit user approval.

8. **Provide configurable prefix-style watch mode** (EXECUTION)
   - Goal: Retain aider-style editor annotations with the preferred `!AI` and `?AI` syntax.
   - Status (Step 8): TODO
   - Approach: Based on Step 2, install the selected watcher source or create the smallest maintainable derivative. Add an explicit marker-position configuration rather than hardcoding personal syntax, and configure prefix mode with `!AI` for edit requests and `?AI` for questions. Decide and document the context-anchor spelling if context anchors are retained. Preserve the existing watcher's debounce, busy queue, marker ledger, loop prevention, bounded snippets, cleanup after `agent_settled`, project ignores, and `session_shutdown` resource cleanup. Keep watch-triggered messages ordinary session messages so they naturally fall after an active sortie boundary. Add focused parser and lifecycle tests for prefix syntax and ensure suffix syntax can remain available if compatibility is inexpensive.

9. **Validate the complete workflow end to end** (EXECUTION)
   - Goal: Demonstrate that pi-native Sortie is a credible replacement before cutover.
   - Status (Step 9): TODO
   - Approach: Exercise normal start/work/return, native branch-summary hand-back, explicit cancellation, duplicate starts, stale persisted state, `/reload`, process restart/resume, summary cancellation/failure, repo-map generation failure, and selected files modified during the branch. Inspect actual provider context to prove that pre-sortie conversation is absent while system/project instructions, the kickoff, subsequent tool results, and watch-triggered turns remain present. Test configured and overridden models, unavailable models, missing authentication, thinking-level changes, and restoration of the original branch model after return. Test `!AI` and `?AI` while idle and busy. Run against supported and unsupported repo-map languages. Compare task setup friction, context quality, return summaries, and file changes against the existing `sortie-aider` workflow; fix correctness issues before documenting acceptance.

10. **Evaluate future first-party repository-map options** (INVESTIGATION)
   - Goal: Define an evidence-based path beyond the initial provider without expanding the first migration unnecessarily.
   - Status (Step 10): TODO
   - Approach: Use Step 2 and Step 9 results to compare four options: retain `pi-repomap`; extend/fork it with C++, Rust, Go, and Kotlin tree-sitter grammars and tag queries; build a broad-language ctags-first mapper; or port aider's Apache-2.0 pipeline to TypeScript. For each, record expected effort, language coverage, grammar/query maintenance, definition/reference quality, PageRank/personalization behavior, token-budget rendering, cache invalidation, malformed-source handling, runtime dependencies, and licensing/attribution obligations. Define measurable replacement criteria and the stable `RepoMapProvider` contract a replacement must satisfy. Do not implement a replacement in this step.
   - Sources: `https://github.com/sn-kaier/pi-repomap`, `https://github.com/Aider-AI/aider/blob/main/aider/repomap.py`, `https://raw.githubusercontent.com/Aider-AI/aider/main/LICENSE.txt`.

11. **Document staged cutover and rollback** (EXECUTION)
   - Goal: Make adoption reversible and define when the aider fallback can be removed.
   - Status (Step 11): TODO
   - Approach: Document installation, configuration, default model selection, per-sortie override, prefix watcher syntax, lifecycle commands, `/tree` labels, isolated-context behavior, repo-map limitations, and troubleshooting. Define trial-period acceptance criteria covering context isolation, branch-summary usefulness, watcher reliability, model restoration, and representative language support. Keep `sortie-aider` available during the trial, document how to choose either workflow, and specify rollback steps. Describe the eventual manual deletion procedure and prerequisites, but do not automatically delete the fallback.

## Notes
- `ctx.navigateTree()` is available only to extension command handlers; do not call it from ordinary event hooks or tools.
- Context filtering changes only what is sent to the model. It must not delete or rewrite parent session history, because that history is required for navigation and branch summarization.
- The context-boundary representation must be recognizable after serialization and reload without relying solely on process-local state.
- Reconstruct persisted workflow state from the current branch, not from the latest matching entry in the complete session file.
- Session replacement and reload invalidate captured contexts and extension instances. Follow the replacement-session restrictions documented in `extensions.md` and clean up long-lived resources on `session_shutdown`.
- A model must be validated before workflow state is mutated; default-value logic does not catch model lookup or authentication failures.
- The initial repo-map provider's narrow language coverage is a product limitation to expose clearly, not a reason to silently claim aider parity.
- Directly translated aider code remains subject to Apache-2.0 attribution and redistribution requirements even if placed inside an otherwise differently licensed package.
- The existing watch extension appears close to the desired behavior, but its prefix-marker change and license must be confirmed from source before implementation.
