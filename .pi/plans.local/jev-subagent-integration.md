# Task: Add Jev (TypeSafe 1.13 via OpenRouter) to Consult and Subagent Architecture

**Status**: Draft — Ready for execution

## References
- `.pi/notes.local/model-escalation-workflow-2026-07-15.md` — Prior design on consult workflows and escalation agents
- `~/.pi/agent/skills/consult/SKILL.md` — Current consult skill specification and shorthand mappings
- `~/.pi/agent/models.json` — Models configuration defining `typesafe/jev-1.13` under OpenRouter

## Context
- Jev 1.13 is a fast, low-cost ($0.042/1M tokens) structured decision / System One model from TypeSafe AI.
- The model is already configured under the `openrouter` provider as `typesafe/jev-1.13` in `~/.pi/agent/models.json`.
- The existing `/consult` skill and `subagent` extension provide an isolated subagent execution harness (`~/.config/dotfiles/.pi/agent/agents/` symlinked into `~/.pi/agent/agents/`).
- Adding Jev as a consult agent (`consult-jev` / `jev`) enables the parent agent and any calling skills/agents to delegate fast, structured classifications, decision trees, and triage to Jev via `subagent` or `/consult --model jev <task>`.

## Design Decisions
- **Provider & Auth**: Route through OpenRouter (`typesafe/jev-1.13`) using existing OpenRouter credentials, avoiding custom API key management.
- **Agent Roles**: Provide `consult-jev.md` (and a `jev.md` alias if needed) in `~/.config/dotfiles/.pi/agent/agents/` with zero tools (`tools: []`) and concise instructions for fast decision-making, classification, and probability scoring.
- **Skill Integration**: Add `jev` shorthand to `~/.pi/agent/skills/consult/SKILL.md` so `/consult --model jev <prompt>` resolves to `consult-jev`.

## Key Sources
- `/home/namalkanti/.pi/agent/models.json` — Model definition for `typesafe/jev-1.13`
- `/home/namalkanti/.pi/agent/skills/consult/SKILL.md` — Consult skill definition and shorthand parser
- `/home/namalkanti/.config/dotfiles/.pi/agent/agents/` — Dotfiles subagent markdown definitions
- `/home/namalkanti/.pi/agent/agents/` — Active subagent links loaded by the `subagent` extension

## Proposed Steps

1. **Investigate Jev Response Behavior via OpenRouter** (INVESTIGATION)
   - Goal: Confirm `typesafe/jev-1.13` availability and response characteristics over OpenRouter chat completions.
   - Status (Step 1): TODO
   - Approach: Inspect model settings in `models.json` and test direct call viability with minimal prompt context.
   - Sources: `~/.pi/agent/models.json`

2. **Create Jev Agent Definition in Dotfiles** (EXECUTION)
   - Goal: Create the subagent configuration file for Jev.
   - Status (Step 2): TODO
   - Approach:
     - Write `~/.config/dotfiles/.pi/agent/agents/consult-jev.md` with `name: consult-jev`, `model: typesafe/jev-1.13`, and a system prompt focused on structured decisions, criteria evaluation, and classification.
     - Create a symlink `~/.pi/agent/agents/consult-jev.md -> ~/.config/dotfiles/.pi/agent/agents/consult-jev.md`.
     - Optionally add `jev.md` link if direct `subagent(agent: "jev")` naming is desired.

3. **Update Consult Skill Shorthand Mapping** (EXECUTION)
   - Goal: Allow `/consult --model jev` invocations.
   - Status (Step 3): TODO
   - Approach:
     - Edit `~/.pi/agent/skills/consult/SKILL.md` to add `jev` to the description and the valid shorthands list (`opus`, `sonnet`, `sol`, `jev`).

4. **Verify Jev Subagent & Consult Skill Invocation** (EXECUTION)
   - Goal: Ensure downstream agents and users can cleanly invoke Jev.
   - Status (Step 4): TODO
   - Approach:
     - Verify agent discovery via subagent loader.
     - Execute a test subagent call against `consult-jev` to verify structured reasoning/decision output.

## Notes
- Jev has a 32K context window and is optimized for low-latency decision and scoring tasks rather than long prose generation.
- Because it has no tools, prompts sent to Jev must be fully self-contained with all relevant state/criteria packaged inline.
