## Commands

- Fast build: `cmake --build build`
- Unit / calculation tests: `ctest --test-dir build --output-on-failure -L unit`
- Full test suite: `ctest --test-dir build --output-on-failure`

## Language-Specific Style & Modeling

- **Pure Calculations & Immutability**:
  - Implement calculations as free functions or pure static methods taking `const&` or value types and returning newly constructed state.
  - No side effects, global state access, or hidden I/O within calculation modules.
- **Error Handling**:
  - Lean toward monadic error handling for domain calculations using `std::expected` / result types rather than throwing exceptions or using sentinel return codes.
- **Resource Management & Ownership**:
  - Strict RAII. No manual memory management or raw owning pointers.
  - Default to `std::unique_ptr` for exclusive heap allocation; reserve `std::shared_ptr` strictly for genuine shared ownership.
- **Modern Idioms**:
  - Use view types (`std::string_view`, `std::span`) for read-only parameters instead of copying or passing raw pointer + length.
  - Mark functions and local variables `const` or `constexpr` by default.

## Testing Conventions

- **Top-Down Test Layout**:
  - Place high-level scenario test cases at the top of the test file.
  - Custom matchers, printers, and fixture helpers reside at the bottom.
- **Assertion Helpers**:
  - Encapsulate non-trivial comparisons (floating-point deltas, physical/geometric thresholds) into domain-specific assertion helpers with descriptive failure output.
