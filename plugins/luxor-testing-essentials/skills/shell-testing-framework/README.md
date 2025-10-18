# Shell Testing Framework Skill

Comprehensive testing expertise for bash shell scripts using patterns from unix-goto.

## Overview

This skill provides systematic testing expertise for shell scripts, including:

- **Test Structure**: Standard arrange-act-assert pattern
- **Four Test Categories**: Unit, integration, edge cases, performance
- **Assertion Patterns**: Comprehensive validation patterns
- **100% Coverage**: Requirements and techniques for complete coverage
- **Performance Testing**: Measuring and validating performance targets
- **Test Organization**: File structure, naming, and execution
- **Best Practices**: Independence, meaningful failures, execution speed

## When to Use

Use this skill when:
- Writing test suites for bash shell scripts
- Implementing 100% test coverage requirements
- Organizing tests into systematic categories
- Creating assertion patterns for validation
- Writing performance tests for shell functions
- Setting up test infrastructure and helpers
- Generating test reports and summaries
- Debugging test failures

## Key Features

### The 100% Coverage Rule
Every core feature requires complete test coverage:
- Every function tested
- Every code path exercised
- Every error condition validated
- Every edge case covered
- Every performance target verified

### Four Test Categories

**1. Unit Tests**
- Test individual functions in isolation
- Fast execution (<1ms per test)
- Clear, focused assertions
- Minimal dependencies

**2. Integration Tests**
- Test how modules work together
- Realistic workflows
- End-to-end behavior validation
- Moderate execution time (<100ms)

**3. Edge Cases**
- Boundary conditions
- Unusual but valid inputs
- Error scenarios
- Resource limits

**4. Performance Tests**
- Measure execution time
- Compare against targets
- Statistical analysis
- Test at scale

### Arrange-Act-Assert Pattern

Every test follows this three-phase structure:
```bash
test_feature() {
    # Arrange - Set up test conditions
    local input="test-value"
    local expected="expected-result"

    # Act - Execute the code under test
    local result=$(function_under_test "$input")

    # Assert - Verify the results
    if [[ "$result" == "$expected" ]]; then
        pass "Test description"
    else
        fail "Expected '$expected', got '$result'"
    fi
}
```

## Installation

This skill is already installed at:
```
~/Library/Application Support/Claude/skills/shell-testing-framework/
```

## Usage

Simply mention shell testing tasks in your conversation with Claude:

```
"Create a comprehensive test suite for my cache module with 100% coverage"
"Help me write performance tests for this navigation function"
"Generate unit, integration, and edge case tests for bookmark management"
```

Claude will automatically activate this skill and guide you through creating comprehensive test suites.

## Examples

### Example 1: Creating a Complete Test Suite
```
"I need a comprehensive test suite for my cache lookup function.
Include all four test categories with 100% coverage."
```

Claude will generate:
- Unit tests for all code paths
- Integration tests with other modules
- Edge case tests for boundary conditions
- Performance tests against targets
- Test helpers and utilities
- Complete test report generation

### Example 2: Performance Testing
```
"Create performance tests to validate my cache lookup is <100ms"
```

Claude will:
- Create high-precision timing measurements
- Run multiple iterations (10+)
- Calculate statistics (min/max/mean/median/stddev)
- Assert against performance targets
- Generate performance reports

## Skill Contents

- **SKILL.md** (1,334 lines): Complete testing expertise
  - Test structure templates
  - Four test categories
  - Assertion patterns
  - Coverage requirements
  - Performance testing
  - Test helpers library
  - Complete examples
  - Best practices

## Example Test Suite Structure

```bash
#!/bin/bash
# test-module.sh

set -e

# Setup
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/module.sh"

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helpers
pass() { echo "✓ PASS: $1"; ((TESTS_PASSED++)); }
fail() { echo "✗ FAIL: $1"; ((TESTS_FAILED++)); }

# Unit Tests
test_basic_functionality() {
    # Arrange
    local input="test"
    # Act
    local result=$(function_under_test "$input")
    # Assert
    [[ "$result" == "expected" ]] && pass "Basic test" || fail "Basic test"
}

# Run tests
test_basic_functionality

# Summary
echo "Passed: $TESTS_PASSED, Failed: $TESTS_FAILED"
[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
```

## Version

- **Version**: 1.0
- **Created**: October 2025
- **Source**: unix-goto testing patterns
- **Lines**: 1,334

## Related Skills

- **unix-goto-development**: Complete unix-goto development workflow
- **performance-benchmark-specialist**: Advanced performance benchmarking

## License

This skill is created for shell testing based on unix-goto patterns by Manu Tej + Claude Code.
