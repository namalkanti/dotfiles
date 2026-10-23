---
name: project-setup
description: Skill for initializing and configuring project-local context, conventions, and operational guidelines in .pi/AGENTS.md. Uses modular templates for languages and domains, inspects the workspace, asks targeted questions to establish project constraints, and awaits explicit user confirmation before writing or updating.
disable-model-invocation: true
---

# Project Setup

`project-setup` configures project-level context by creating or updating `.pi/AGENTS.md`.
It establishes concrete project conventions—build and test commands, style rules,
and architecture invariants—without duplicating the user's global `AGENTS.md`.

**Hard boundary:** `project-setup` focuses on project context and operational conventions.
It does not plan algorithmic tasks (use `recon` for task planning) and does not write
application logic.

## Workflow

1. **Inspect Workspace.**
   Inspect the repository root and directory structure (e.g. existing manifests like
   `Cargo.toml`, `pyproject.toml`, `CMakeLists.txt`, existing `.pi/AGENTS.md` if present).
   Form an initial hypothesis of the active stack, but do not assume full intent from files alone.

2. **Inquire and Understand.**
   Always engage in discussion to resolve ambiguity and clarify intent before drafting:
   - Primary language(s) and role of the repo (e.g. CLI, service, library, multi-component workspace).
   - Tooling preferences (package manager, runners, linters).
   - Domain invariants or architectural constraints not visible from manifests alone.

3. **Select & Compose Templates.**
   Check `references/templates/` for relevant building blocks:
   - Base structure: `references/templates/base.md`
   - Language templates: `references/templates/languages/<lang>.md`
   - If the project combines languages (e.g. C++/Python FFI, Rust/Python), compose the
     relevant language sections and define boundary rules.

4. **Present Outline / Diff for Review.**
   Present a concise outline of the proposed `.pi/AGENTS.md` content:
   - Selected language and tooling profile.
   - Exact verification commands (fast check vs full suite).
   - Specific coding guidelines, domain modeling rules, and test conventions.
   - If updating an existing `.pi/AGENTS.md`, present the changes as an explicit diff
     or list of proposed modifications to preserve existing project-specific rules.

   **Guardrail:** Do not write anything to disk until the user explicitly reviews
   and approves the proposed outline.

5. **Write or Update `.pi/AGENTS.md`.**
   Once approved:
   - Ensure the `.pi/` directory exists.
   - Write or update `.pi/AGENTS.md`.
   - Keep the file lean (~50–80 lines), operational, and directly relevant to agents running in this repo.
