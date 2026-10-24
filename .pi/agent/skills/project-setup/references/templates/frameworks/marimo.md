## Commands

- Marimo visual check & syntax export: `uv run marimo export html <path/to/notebook.py> -o /tmp/notebook_test.html`
- Run Marimo interactive server: `uv run marimo edit <path/to/notebook.py>`
- Fast unit test check: `uv run pytest tests/`
- Lint & format check: `uv run ruff check .`
- Type check: `uv run pyright`

## Marimo Architecture & DAG Conventions

- **Pure Functional Core vs. UI Shell**:
  - Keep domain calculations, DSP transformations, and data models in pure Python modules (`src/<pkg>/`).
  - Notebook cells act strictly as a presentation shell: calling functions, wiring widgets (`mo.ui.*`), and assembling layouts (`mo.vstack`, `mo.hstack`).
- **Cell Output vs. Variable Export**:
  - In Marimo cells, the **last evaluated expression** is what gets rendered visually in the UI.
  - The trailing `return var_a, var_b` is reserved strictly by Marimo for exporting symbols to the reactive DAG.
  - Pattern for UI cards:
    ```python
    output_card = mo.vstack([
        widget_selector,
        mo.as_html(fig),
    ])
    output_card
    return
    ```
- **Embedding Widgets**:
  - Define widgets in a dedicated setup cell (`widget = mo.ui.dropdown(...)`) and return them to the DAG.
  - Embed the widget directly inside downstream display cells (`mo.vstack([widget, ...])`) to eliminate awkward gaps and separate control bars.
- **DAG Variable Collisions**:
  - Marimo enforces a single-assignment DAG across all cells. Never reuse identical local variable names (e.g. `nperseg`, `fig`, `ax`) across multiple cells unless scoped with an underscore prefix (`_nperseg`) or kept local inside function definitions.

## Linter & LSP Invariants (Ruff + Pyright)

Marimo's cell format evaluates expressions on the final line, uses bare `return` statements for DAG exports, and injects all reactive cell dependencies as function parameters. Standard linters must be configured with per-file ignores for notebook paths:

- **Ruff (`pyproject.toml`)**:
  ```toml
  [tool.ruff.lint.per-file-ignores]
  # B018: unused display expression (Marimo UI rendering)
  # PLR1711: useless return at end of function (Marimo DAG export)
  # I001: unsorted imports across interactive cells
  # PLR0913 / PLR0917: too many arguments / positional arguments (Marimo DAG dependency injection)
  "wk*/*.py" = ["B018", "PLR1711", "I001", "PLR0913", "PLR0917"]
  "labs*/**/*.py" = ["B018", "PLR1711", "I001", "PLR0913", "PLR0917"]
  ```
- **Pyright (`pyrightconfig.json`)**:
  ```json
  {
    "include": ["src", "tests", "wk*"],
    "exclude": ["**/__pycache__", ".venv"],
    "reportUnusedExpression": "warning",
    "executionEnvironments": [
      {
        "root": "wk1",
        "reportUnusedExpression": "none"
      }
    ]
  }
  ```
