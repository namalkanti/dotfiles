# Task: Implement Jev Sentinel Extension for Agent Failure Mode Detection

**Status**: Draft — Ready for execution

## References
- `.pi/notes.local/jev-decision-tool-integration-2026-09-30.md` — Core Jev OpenRouter decisions API integration
- `~/.config/dotfiles/.pi/agent/extensions/jev.ts` — Existing Jev extension tool
- `/usr/lib/node_modules/pi/packages/coding-agent/docs/extensions.md` — Pi extension hooks and event lifecycles

## Context
- LLM agents in autonomous loops frequently succumb to pathological behaviors:
  1. *Test Weakening / Bypass*: Modifying test assertions, deleting test cases, or hardcoding mock branches immediately after a test failure instead of fixing the root cause.
  2. *Circular Edit Thrashing*: Repeatedly editing and reverting the same file/function 3+ times in a futile trial-and-error cycle.
  3. *Blind Retry Spirals*: Re-executing failed tools with identical or trivial parameter variations without diagnosing the underlying cause.
  4. *Runaway Scope Drift*: Wandering into unprompted refactoring across unrelated codebase areas during long tool execution chains.
- Because models enter closed generative thinking loops during a turn, they cannot self-correct mid-thought.
- A harness-level extension hook ("Sentinel") can observe inter-turn events (`tool_call`, `tool_result`, `turn_end`), apply local zero-cost heuristic filters, and invoke TypeSafe Jev 1.13 (`typesafe/jev-1.13` via OpenRouter Decisions API) as an objective, low-latency, low-cost referee when a risk pattern is suspected.
- When Jev confirms an anti-pattern with high calibrated probability (>= 0.8), the sentinel intercepts the action, pausing the runaway loop or injecting a steering notice that forces the agent to explain its hypothesis to the user.

## Design Decisions
- **Two-Tier Architecture**:
  - Tier 1: Local heuristics (free, instantaneous) filter 98%+ of normal turns. Jev is called only when a threshold is breached.
  - Tier 2: Jev 1.13 calibrated decision scoring. Evaluates the semantic intent of the proposed action against the recent failure context.
- **Steering over Crashing**:
  - Rather than terminating the session abruptly, the sentinel injects a synthetic warning notice or blocks the tool with a directive requiring the model to articulate its rationale to the user.
- **Configurable Sensitivities**:
  - Keep thresholds conservative to avoid false positives on routine text mismatches or benign retries.

## Key Sources
- `/usr/lib/node_modules/pi/packages/coding-agent/docs/extensions.md` — Extension event specifications (`tool_call`, `tool_result`, `turn_end`, session tree inspection)
- `~/.config/dotfiles/.pi/agent/extensions/jev.ts` — Jev decision invocation patterns
- `https://openrouter.ai/docs/guides/community/jev` — OpenRouter decisions schema reference

## Proposed Steps

1. **Investigate Extension Lifecycle Hooks & Context Inspection** (INVESTIGATION)
   - Goal: Map pi's extension APIs for tool interception, session history traversal, and dynamic steering message injection.
   - Status (Step 1): TODO
   - Approach: Inspect pi extension docs and examples to identify exact hooks (`tool_call`, `tool_result`, `session_before_turn`) and how to block/annotate tool executions cleanly.
   - Sources: `/usr/lib/node_modules/pi/packages/coding-agent/docs/extensions.md`

2. **Define Heuristic Evaluators & Jev Decision Schemas** (INVESTIGATION)
   - Goal: Specify the exact predicate logic for the 4 trigger heuristics and formulate calibrated Jev questions and criteria for each.
   - Status (Step 2): TODO
   - Approach: Draft TypeScript interfaces and criteria mapping for:
     - Test weakening / bypass detection
     - Circular edit thrashing detection
     - Blind retry spiral detection
     - Runaway scope expansion detection
   - Sources: Prior agent session logs, Jev decision prompt best practices

3. **Implement Sentinel Extension Core** (EXECUTION)
   - Goal: Build the sentinel extension in dotfiles and register it in pi.
   - Status (Step 3): TODO
   - Approach:
     - Write `~/.config/dotfiles/.pi/agent/extensions/sentinel.ts`.
     - Implement state tracking across turns (recent tool calls, recent test exit codes, touched files).
     - Wire Tier 1 heuristic triggers to Tier 2 Jev evaluator.
     - Implement intercept behaviors (tool blocking, warning injection).
     - Symlink `~/.pi/agent/extensions/sentinel.ts -> ~/.config/dotfiles/.pi/agent/extensions/sentinel.ts`.

4. **Verify Sentinel Against Synthetic Failure Traces** (EXECUTION)
   - Goal: Verify each trigger activates correctly on pathological patterns while remaining silent on benign operations.
   - Status (Step 4): TODO
   - Approach:
     - Create test fixtures simulating test failure followed by test modification.
     - Simulate circular editing on a single file across turns.
     - Simulate identical failed bash/edit retry.
     - Run headless pi sessions to verify Jev scoring and intercept messaging.

## Notes
- Jev input budget is 32k tokens, but keeping payloads minimal (recent diff + error snippet, ~500–1,500 tokens) keeps latency under 300ms and cost under $0.0001 per check.
- Normal `edit` mismatches (e.g. slight whitespace issues) should only count toward retry thrashing if the agent repeats the *exact same* failed parameters without inspecting the file.
