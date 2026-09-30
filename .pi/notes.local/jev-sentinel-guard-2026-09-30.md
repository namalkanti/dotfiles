# Jev Sentinel Guard Extension

**Date**: 2026-09-30  
**Status**: Completed

## Summary
Implemented and verified Sentinel Guard (`sentinel.ts`), a Pi extension that intercepts agent pathological failure modes across turns:
1. **Blind Retry Spirals**: Repeating identical failed commands without diagnosing the root cause.
2. **Test Weakening / Bypass**: Directly modifying test files or deleting assertions immediately after a test runner failure.
3. **Circular Edit Thrashing**: Repeatedly editing, oscillating, or toggling changes back and forth on the same file across turns.
4. **Runaway Scope Drift**: Expanding mutations into unrelated files outside the established working set.

The extension employs a two-tier architecture: free zero-cost local heuristic tracking (Tier 1) filters benign turns, offloading suspicious candidates to TypeSafe Jev 1.13 via OpenRouter Decisions API (`POST https://openrouter.ai/api/alpha/decisions`) (Tier 2). When Jev flags an anti-pattern with calibrated intervention probability $\ge 0.8$, Sentinel halts the tool execution and prompts the user for interactive confirmation via `ctx.ui.confirm()`.

## Architecture & Design Decisions
- **Human Review Gate**:
  - Jev acts as an objective, low-latency, calibrated referee; the human user decides whether to allow or block the flagged tool call.
  - User rejection returns `{ block: true, reason }` back to the agent loop with diagnostic guidance.
- **Fail-Open Safety**:
  - Network errors, Jev timeouts (bounded to 3.5s), missing API key, or non-interactive headless modes (`!ctx.hasUI`) pass tool calls through cleanly without crashing or interrupting operations.
- **Intervening Diagnosis Reset**:
  - Diagnostic actions (`read`, `grep`, `find`, `ls`) immediately clear retry spiral sensitivity, allowing models to retry commands after inspecting context.
- **Oscillation Evidence Payload**:
  - Circular edit detection tracks historical diff payloads per file to provide concrete evidence of cycling/toggling to Jev, preventing false positives on legitimate multi-step file authoring.

## Critical Files
- `~/.config/dotfiles/.pi/agent/extensions/sentinel.ts` — Sentinel extension implementation
- `~/.pi/agent/extensions/sentinel.ts` — Active symlink loaded by Pi
- `~/.config/dotfiles/.pi/agent/extensions/jev.ts` — Native `jev_decide` tool implementation

## Verification Highlights
- Verified live against OpenRouter `typesafe/jev-1.13` Decisions API using synthetic test traces covering all four anti-patterns, benign operations, diagnostic clearing, and headless fail-open passthrough (16/16 assertions passed).
