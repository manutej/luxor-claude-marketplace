# Performance Benchmark Specialist Skill

Advanced performance benchmarking expertise for shell tools with statistical analysis and comprehensive reporting.

## Overview

This skill provides rigorous performance benchmarking expertise, including:

- **Benchmark Design**: Standard structure and patterns
- **Statistical Analysis**: min/max/mean/median/standard deviation
- **Performance Targets**: <100ms navigation, >90% cache hit rate, >20x speedup
- **Workspace Generation**: Test environments at multiple scales
- **Results Storage**: CSV format with historical tracking
- **Comprehensive Reporting**: Professional benchmark output
- **Helper Library**: Complete benchmarking utilities

## When to Use

Use this skill when:
- Creating performance benchmarks for shell scripts
- Measuring and validating performance targets
- Implementing statistical analysis for results
- Designing benchmark workspaces and test environments
- Comparing baseline vs optimized performance
- Generating performance reports
- Storing benchmark results for trend analysis
- Validating performance regressions

## Key Features

### Performance-First Development

Performance is a core requirement, not an afterthought:
1. Define targets BEFORE implementation
2. Measure EVERYTHING that matters
3. Use statistical analysis, not single runs
4. Test at realistic scale
5. Validate against targets automatically

### Performance Targets (unix-goto)

| Metric | Target | Rationale |
|--------|--------|-----------|
| Cached navigation | <100ms | Sub-100ms feels instant |
| Bookmark lookup | <10ms | Near-instant access |
| Cache speedup | >20x | Significant improvement |
| Cache hit rate | >90% | Most queries cached |
| Cache build | <5s | Fast initial setup |

### Statistical Analysis

Every benchmark calculates:
- **Min**: Best case performance
- **Max**: Worst case performance
- **Mean**: Average performance (primary metric)
- **Median**: Middle value (better for skewed distributions)
- **Standard Deviation**: Consistency measure

### Benchmark Helper Library

Complete set of utilities:
- `bench_time_ms`: High-precision timing
- `bench_calculate_stats`: Statistical analysis
- `bench_run`: Complete benchmark execution
- `bench_warmup`: Reduce measurement noise
- `bench_create_workspace`: Generate test environments
- `bench_print_stats`: Professional output formatting
- `bench_assert_target`: Automatic target validation
- `bench_save_result`: CSV storage
- `bench_compare`: Speedup calculation

## Installation

This skill is already installed at:
```
~/Library/Application Support/Claude/skills/performance-benchmark-specialist/
```

## Usage

Simply mention performance benchmarking tasks in your conversation with Claude:

```
"Create a benchmark to measure cached vs uncached navigation performance"
"Help me benchmark cache performance at different scales (10, 50, 500 folders)"
"Generate a comprehensive benchmark suite with statistical analysis"
```

Claude will automatically activate this skill and guide you through creating rigorous benchmarks.

## Examples

### Example 1: Cached vs Uncached Comparison
```
"Create a benchmark comparing cached vs uncached navigation performance.
Include statistical analysis and speedup calculation."
```

Claude will generate:
- Phase 1: Uncached baseline measurement
- Phase 2: Cached optimized measurement
- Statistical analysis for both phases
- Speedup ratio calculation
- Performance target assertions
- CSV results storage
- Professional report generation

### Example 2: Scalability Testing
```
"Benchmark cache performance at 10, 50, 500, and 1000 folders.
Verify all scale points meet the <100ms target."
```

Claude will:
- Create workspaces at each scale
- Run benchmarks with proper warmup
- Calculate statistics for each scale
- Adjust targets based on scale
- Generate comparative analysis
- Store results for trend tracking

### Example 3: Complete Benchmark Suite
```
"Create a comprehensive benchmark suite covering:
- Cached vs uncached performance
- Multi-level path navigation
- Cache build performance
- Parallel concurrent access
Store all results in CSV format."
```

## Skill Contents

- **SKILL.md** (1,192 lines): Complete benchmarking expertise
  - Standard benchmark structure
  - Helper library (complete implementation)
  - Benchmark patterns (3 detailed patterns)
  - Statistical analysis methods
  - Workspace generation utilities
  - Results storage and analysis
  - Professional reporting
  - Best practices

## Example Benchmark Structure

```bash
#!/bin/bash
# Benchmark: Feature Performance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bench-helpers.sh"

main() {
    bench_header "Benchmark Title"

    # Setup workspace
    local workspace=$(bench_create_workspace "medium")

    # Warmup
    bench_warmup "command" 3

    # Run benchmark
    local stats=$(bench_run "name" "command" 10)

    # Analyze
    IFS=',' read -r min max mean median stddev <<< "$stats"
    bench_print_stats "$stats" "Results"

    # Assert target
    bench_assert_target "$mean" 100 "Performance"

    # Save
    bench_save_result "benchmark" "$stats" "operation"

    # Cleanup
    bench_cleanup_workspace "$workspace"
}

main
exit 0
```

## Benchmark Output Format

```
╔══════════════════════════════════════════════════════════════════╗
║  Cached vs Uncached Navigation Performance                      ║
╚══════════════════════════════════════════════════════════════════╝

Phase 1: Uncached lookup (no cache)
─────────────────────────────────
  Run  1: 215ms
  Run  2: 208ms
  ...

Results:
  Min:                                             203ms
  Max:                                             229ms
  Mean:                                            215ms
  Median:                                          214ms
  Std Dev:                                        7.12ms

Phase 2: Cached lookup (with cache)
─────────────────────────────────
  Run  1: 26ms
  Run  2: 24ms
  ...

Results:
  Min:                                              23ms
  Max:                                              30ms
  Mean:                                             26ms
  Median:                                           26ms
  Std Dev:                                        2.01ms

Performance Analysis:
  Speedup ratio:                               8.27x

✓ Cached navigation time meets target: 26ms (target: <100ms)
```

## CSV Results Format

```csv
timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata
1704123456,cached_vs_uncached,uncached,203,229,215,214,7.12,
1704123456,cached_vs_uncached,cached,23,30,26,26,2.01,
```

## Version

- **Version**: 1.0
- **Created**: October 2025
- **Source**: unix-goto benchmark patterns
- **Lines**: 1,192

## Related Skills

- **unix-goto-development**: Complete development workflow
- **shell-testing-framework**: Comprehensive testing patterns

## License

This skill is created for performance benchmarking based on unix-goto patterns by Manu Tej + Claude Code.
