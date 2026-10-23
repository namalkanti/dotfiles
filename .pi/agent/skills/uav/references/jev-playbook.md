# Jev Decision Playbook for UAV Runs

This playbook defines calibrated usage patterns for the `jev_decide` co-processor during Pi-backed UAV autonomous missions.

> **Scope Note**: `jev_decide` is exclusively available to Pi runners (`pi`). Missions dispatched to Claude Code or Codex CLI must omit all references to Jev.

---

## What Jev Is and When to Use It

`jev_decide` interfaces directly with `typesafe/jev-1.13` (via OpenRouter decisions endpoint). It is a high-speed, calibrated scoring and classification engine designed to make impartial choices against explicit rubrics without conversational baggage.

In UAV missions, Jev acts as:
1. An **anti-spiral circuit breaker** (breaking doom loops on persistent errors).
2. An **architectural arbiter** (evaluating competing design paths against acceptance criteria).
3. A **completion validator** (calibrated scoring of whether a mission is genuinely complete).

---

## Playbook 1: Anti-Spiral Circuit Breaker

### When to Trigger
- You have made **two consecutive attempts** to fix the same compilation error, runtime crash, or failing test without progress.
- You find yourself repeatedly re-editing the same 1-2 files back and forth.

### Tool Call Pattern
```json
{
  "question": "Two consecutive attempts to resolve this test failure have failed. Which strategic pivot should be taken?",
  "type": "choice",
  "state": "Test output: [paste concise failure output]. Attempt 1: tried modifying X. Attempt 2: tried patching Y. Problem persists.",
  "criteria": {
    "pivot_architecture": "The failure indicates an underlying flawed assumption or wrong abstraction level; pivot the implementation approach.",
    "isolate_subsystem": "The failure may be an environment, test harness, or side-effect issue; isolate the failing unit with a minimal reproduction.",
    "declare_roadblock": "The task requires missing dependencies, unstated domain requirements, or changes outside the assigned scope; stop and report as PARTIAL in debrief."
  }
}
```

### Action Following Verdict
- Follow the winning option immediately.
- If `declare_roadblock` is selected: commit current working changes, write debrief as `PARTIAL`, note Jev's evaluation, and exit cleanly. Do not continue spiraling.

---

## Playbook 2: Architectural Fork Arbiter

### When to Trigger
- While implementing the mission objective, you uncover two or more viable implementation strategies with differing trade-offs (e.g. modifying an existing struct vs introducing a new trait/interface).

### Tool Call Pattern
```json
{
  "question": "Which implementation pattern better satisfies project conventions and minimal abstraction principles?",
  "type": "choice",
  "state": "Objective: [task objective]. Candidate A: [describe option A]. Candidate B: [describe option B].",
  "criteria": {
    "option_a": "Minimizes changes to existing callers and maintains backwards compatibility.",
    "option_b": "Introduces a cleaner boundary and reduces long-term duplication, but modifies call sites."
  }
}
```

### Action Following Verdict
- Execute the chosen candidate. Record the question and decision in the debrief under `### Jev Consultations`.

---

## Playbook 3: Completion & Acceptance Sanity Gate

### When to Trigger
- All code changes are written, tests pass, and you are preparing to write the debrief and finish the run.

### Tool Call Pattern
```json
{
  "question": "How thoroughly and cleanly does the current implementation satisfy the mission acceptance criteria?",
  "type": "score",
  "state": "Acceptance criteria: [list criteria]. Verification commands run: [build/test outputs]. Changes made: [git diff stat summary].",
  "criteria": {
    "readiness": "1.0 means all criteria strictly met with passing tests and no leftover debt; 0.0 means completely broken or incomplete."
  }
}
```

### Action Following Verdict
- **Score >= 0.85**: Mark status as `SUCCESS` in debrief, commit, and exit.
- **Score < 0.85**: Review the weak criteria identified by Jev. If addressable within the current mission turn budget, address them; otherwise mark status as `PARTIAL` with specific gaps documented in the debrief.

---

## What NOT to Call Jev For (Anti-Patterns)

- **Do NOT use Jev for trivial syntax or naming**: Choose clear names yourself; do not burn round-trips on variable naming.
- **Do NOT invoke Jev on every turn**: Jev is a co-processor for forks and spirals, not a micro-manager. A typical UAV run should invoke Jev 0 to 2 times total.
- **Do NOT pass massive multikilobyte logs**: Keep the `state` field concise and focused on the core problem.
