# Base Template Structure

When constructing or updating `.pi/AGENTS.md`, focus strictly on project-local operational constraints, architectural style, and testing idioms. Do not duplicate global `~/.pi/agent/AGENTS.md` context (personal background, general tool rules, communication style).

## Core Architectural Invariants (Applies across all projects)

- **Functional Separation (Data / Calculations / Actions)**:
  - **Data**: Passive facts and domain representations with no behavior or hidden state.
  - **Calculations**: Pure functions (data in, data out). Deterministic, no side effects, no mutation of external state, no I/O, disk, or network calls. Calculations are the primary targets for rapid, repeatable agentic TDD without mocks.
  - **Actions**: Code whose execution depends on when or how many times it is run (I/O, database, network, clock, hardware, side effects). Keep actions thin; push business logic into calculations and call them from actions.

- **Top-Down Reading Order & Two-Phase Development**:
  - **Phase 1 (Draft First)**: Get the calculation/action working and verified with tests. Avoid premature abstraction while iterating on algorithms or logic.
  - **Phase 2 (Refactor to Newspaper Layout)**: Before declaring work complete, refactor modules into a clear top-down layout:
    - **Named Constants at Top**: Hoist magic numbers, mathematical/physical thresholds, and tolerances to named module constants.
    - **Public Entry Points / Orchestrators First**: Primary functions, public APIs, and types sit directly below constants (< 35–40 lines each). Function names should document the operational pipeline.
    - **Explicit Helper Section at Bottom**: Decomposed single-responsibility helper functions sit at the bottom under an explicit divider (e.g. `# --- Helper Functions ---` or `// --- Helper Functions ---`).

- **Self-Documenting & Domain-Explicit**:
  - Prefer intention-revealing naming over explanatory comments. If a function exceeds ~40 lines or performs multiple distinct steps, decompose it into named helpers at the bottom.
  - Comments and docstrings justify the *why*, physical/mathematical models, and non-obvious domain units rather than paraphrasing code.

## Core Testing Conventions (Applies across all projects)

- **Top-Down Test Structure**:
  - High-level test cases (acting as executable specifications of scenarios) reside at the top of the test module.
  - Assertion helpers, fixture factories, and setup mechanics reside at the bottom.
- **Domain Assertions**:
  - Avoid raw boolean or scalar assertions in test bodies for domain logic.
  - Write named `assert_*` helper functions that capture domain physics, business invariants, or algebraic properties.
  - Assertion helpers must provide descriptive failure messages containing domain units (e.g. dB, Hz, counts, currency).
- **Scenario-Driven Test Names**:
  - Test function names reflect the scenario being exercised and expected outcome, not the name of a method.

## Standard Sections for `.pi/AGENTS.md`

1. **Project Overview**: Purpose, domain, and scope of the repo.
2. **Commands**: Non-interactive verification commands (fast check for calculations vs full verification).
3. **Coding Style & Domain Modeling**: Language-specific expressions of D/C/A, type idioms, and invariants.
4. **Testing Conventions**: Framework-specific application of top-down tests and domain assertion helpers.
5. **Project Invariants**: Hard boundaries (e.g. error boundary policies, memory ownership constraints, forbidden dependencies).
