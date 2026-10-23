## Commands

- Fast check: `cargo check`
- Calculation / unit tests: `cargo test --lib`
- Full test suite: `cargo test`
- Lint: `cargo clippy --all-targets --all-features -- -D warnings`
- Format check: `cargo fmt --check`
- Format apply: `cargo fmt`

## Language-Specific Style & Modeling

- **Domain Modeling via Value Types**:
  - Encapsulate primitive domain quantities in dedicated newtypes or value structs (e.g. `Dollars`, `Timestamp`) to enforce invariants at compile time.
  - Implement operator traits (`Add`, `Sub`, `Mul`, `Sum`) and `Display` directly on value types so pure calculations read naturally.
- **Pure Calculations**:
  - Calculation functions take borrowed state (`&T`), return new value types, `Option<T>`, or `Result<T, E>`, and avoid interior mutability or hidden side effects.
  - Keep domain calculations independent of runtime I/O dependencies.
- **Error Handling**:
  - Model domain errors with explicit enums.
  - No bare `.unwrap()` or `.expect()` in non-test paths.
  - Boundary layers sanitize internal errors before exposing messages outward.

## Testing Conventions

- **Module Layout**:
  - Unit tests reside in `mod tests { use super::*; ... }` at the bottom of the source file.
  - *Inside* `mod tests`, high-level scenario test functions come first, followed by assertion helpers and test fixture constructors at the bottom.
  - Public integration tests reside in `tests/`.
- **Top-Down Test Modules**:
  - In integration test files under `tests/`, place high-level scenario tests at the top and helper fixtures at the bottom.
