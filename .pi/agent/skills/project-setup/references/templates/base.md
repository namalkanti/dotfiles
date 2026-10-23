# Base Template Structure

When constructing or updating `.pi/AGENTS.md`, focus strictly on project-local operational constraints, architectural style, and testing idioms. Do not duplicate global `~/.pi/agent/AGENTS.md` context (personal background, general tool rules, communication style).

## Core Architectural Invariants (Applies across all projects)

- **Functional Separation (Data / Calculations / Actions)**:
  - **Data**: Passive facts and domain representations with no behavior or hidden state.
  - **Calculations**: Pure functions (data in, data out). Deterministic, no side effects, no mutation of external state, no I/O, disk, or network calls. Calculations are the primary targets for rapid, repeatable agentic TDD without mocks.
  - **Actions**: Code whose execution depends on when or how many times it is run (I/O, database, network, clock, hardware, side effects). Keep actions thin; push business logic into calculations and call them from actions.

- **Top-Down Reading Order**:
  - Modules and files read top-to-bottom: high-level intent, public types, and primary specifications at the top; lower-level implementation mechanics, trait/interface plumbing, and private helper functions toward the bottom.

- **Self-Documenting & Domain-Explicit**:
  - Prefer intention-revealing naming over explanatory comments.
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
