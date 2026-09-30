# Jev Decision Tool Integration

**Date**: 2026-09-30  
**Status**: Completed

## Summary
Integrated TypeSafe's Jev 1.13 (`typesafe/jev-1.13` via OpenRouter) into `pi` as a native custom extension tool (`jev_decide`). This enables agents and interactive sessions to offload fast, low-cost, calibrated classification and decision-making without chat completion token overhead.

## Architecture & Design Decisions
- **Decisions Model vs Chat Model**:
  - `typesafe/jev-1.13` is an OpenRouter System One model. It rejects `/chat/completions` (HTTP 400) and only accepts structured schema payloads on `POST /api/alpha/decisions`.
  - Because `subagent` extension spawns standalone `pi` CLI processes expecting conversational message streaming, Jev cannot be executed as a plain chat subagent markdown definition.
- **Direct Tool Extension**:
  - Implemented as a custom tool extension (`jev_decide`) in `~/.config/dotfiles/.pi/agent/extensions/jev.ts`, symlinked to `~/.pi/agent/extensions/jev.ts`.
  - Tool parameters accept `state` (string or object), `question` (instruction string), `type` (`choice`, `noul`, or `score`), and `criteria` (record mapping labels to rubric text).
  - Kept as a direct, unadorned model tool rather than a slash skill to minimize latency and ceremony when called inside interactive sessions.

## Critical Files
- `~/.config/dotfiles/.pi/agent/extensions/jev.ts` — Extension implementation registering `jev_decide`
- `~/.pi/agent/extensions/jev.ts` — Active symlink loaded by pi
- `~/.pi/agent/models.json` — Model definition for OpenRouter `typesafe/jev-1.13`

## History Highlights
- Investigated OpenRouter endpoint behavior; confirmed HTTP 400 on chat completions and HTTP 200 on `/api/alpha/decisions`.
- Implemented `jev_decide` extension using TypeBox and direct `fetch`.
- Verified live invocation end-to-end via headless `pi` agent process.
- Executed self-assessment query with Jev over plan state, confirming 0.95 completion confidence.
