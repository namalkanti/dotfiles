## Commands

- Fast calculation / unit check: `uv run pytest tests/ -k "not integration"`
- Full test suite: `uv run pytest`
- Lint & format check: `uv run ruff check . && uv run ruff format --check .`
- Type check: `uv run mypy .`

## Language-Specific Style & Modeling

- **Calculations & Purity**:
  - Implement calculations as standalone pure functions or `@staticmethod` functions taking immutable inputs.
  - In signatures for pure calculations, prefer immutable types (`Sequence`, `Mapping`, `tuple`) over mutable collections (`list`, `dict`) to prevent accidental in-place mutation.
  - Return new data instances or transformed copies rather than mutating inputs.
- **Typing & Signatures**:
  - Full type annotations on all function signatures and non-trivial local variables.
  - Avoid `Any`; prefer precise generics, `Protocol`, or standard unions.
- **Data Modeling**:
  - Prefer immutable data structures (`dataclasses(frozen=True, slots=True)` or `NamedTuple`) for domain Data.
  - Isolate external data schema parsing at boundaries.

## Testing Conventions

- **Pytest Top-Down Layout**:
  - Place `test_*` scenario functions at the top of the file.
  - Colocate private `assert_*` domain helpers at the bottom of the module.
- **Assertion Helpers**:
  - Encapsulate mathematical/scientific tolerances (e.g. `pytest.approx`) and unit comparisons inside domain assertion helpers.
