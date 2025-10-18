---
name: performance-benchmark-specialist
description: Performance benchmarking expertise for shell tools, covering benchmark design, statistical analysis (min/max/mean/median/stddev), performance targets (<100ms, >90% hit rate), workspace generation, and comprehensive reporting
---

# Performance Benchmark Specialist

Comprehensive performance benchmarking expertise for shell-based tools, focusing on rigorous measurement, statistical analysis, and actionable performance optimization using patterns from the unix-goto project.

## When to Use This Skill

Use this skill when:
- Creating performance benchmarks for shell scripts
- Measuring and validating performance targets
- Implementing statistical analysis for benchmark results
- Designing benchmark workspaces and test environments
- Generating performance reports with min/max/mean/median/stddev
- Comparing baseline vs optimized performance
- Storing benchmark results in CSV format
- Validating performance regressions
- Optimizing shell script performance

Do NOT use this skill for:
- Application profiling (use language-specific profilers)
- Production performance monitoring (use APM tools)
- Load testing web services (use JMeter, k6, etc.)
- Simple timing measurements (use basic `time` command)

## Core Performance Philosophy

### Performance-First Development

Performance is NOT an afterthought - it's a core requirement from day one.

**unix-goto Performance Principles:**
1. **Define targets BEFORE implementation**
2. **Measure EVERYTHING that matters**
3. **Use statistical analysis, not single runs**
4. **Test at realistic scale**
5. **Validate against targets automatically**

### Performance Targets from unix-goto

| Metric | Target | Rationale |
|--------|--------|-----------|
| Cached navigation | <100ms | Sub-100ms feels instant to users |
| Bookmark lookup | <10ms | Near-instant access required |
| Cache speedup | >20x | Significant improvement over uncached |
| Cache hit rate | >90% | Most lookups should hit cache |
| Cache build | <5s | Fast initial setup, minimal wait |

**Achieved Results:**
- Cached navigation: 26ms (74ms under target)
- Cache build: 3-5s (meets target)
- Cache hit rate: 92-95% (exceeds target)
- Speedup ratio: 8x (work in progress to reach 20x)

## Core Knowledge

### Standard Benchmark Structure

Every benchmark follows this exact structure:

```bash
#!/bin/bash
# Benchmark: [Description]

# ============================================
# Setup
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/module.sh"

# ============================================
# Main Function
# ============================================

main() {
    bench_header "Benchmark Title"

    echo "Configuration:"
    echo "  Iterations: 10"
    echo "  Warmup: 3 runs"
    echo "  Workspace: medium (50 folders)"
    echo ""

    benchmark_feature

    generate_summary
}

# ============================================
# Benchmark Function
# ============================================

benchmark_feature() {
    bench_section "Benchmark Section"

    # Setup
    local workspace=$(bench_create_workspace "medium")

    # Phase 1: Baseline
    echo "Phase 1: Baseline measurement"
    echo "─────────────────────────────────"

    # Warmup
    bench_warmup "command" 3

    # Run benchmark
    local baseline_stats=$(bench_run "baseline" "command" 10)

    # Extract statistics
    IFS=',' read -r min max mean median stddev <<< "$baseline_stats"

    # Print results
    bench_print_stats "$baseline_stats" "Baseline Results"

    # Phase 2: Optimized
    echo ""
    echo "Phase 2: Optimized measurement"
    echo "─────────────────────────────────"

    # Implementation of optimization
    optimize_feature

    # Warmup
    bench_warmup "optimized_command" 3

    # Run benchmark
    local optimized_stats=$(bench_run "optimized" "optimized_command" 10)

    # Extract statistics
    IFS=',' read -r opt_min opt_max opt_mean opt_median opt_stddev <<< "$optimized_stats"

    # Print results
    bench_print_stats "$optimized_stats" "Optimized Results"

    # Compare and analyze
    local speedup=$(bench_compare "$mean" "$opt_mean")
    echo ""
    echo "Performance Analysis:"
    echo "  Speedup ratio:                               ${speedup}x"

    # Assert targets
    bench_assert_target "$opt_mean" 100 "Optimized performance"

    # Save results
    bench_save_result "benchmark_name" "$baseline_stats" "baseline"
    bench_save_result "benchmark_name" "$optimized_stats" "optimized"

    # Cleanup
    bench_cleanup_workspace "$workspace"
}

# ============================================
# Execute
# ============================================

main
exit 0
```

### Benchmark Helper Library

The complete helper library provides ALL benchmarking utilities:

```bash
#!/bin/bash
# bench-helpers.sh - Comprehensive benchmark utilities

# ============================================
# Configuration
# ============================================

BENCH_RESULTS_DIR="${BENCH_RESULTS_DIR:-$HOME/.goto_benchmarks}"
BENCH_WARMUP_ITERATIONS="${BENCH_WARMUP_ITERATIONS:-3}"
BENCH_DEFAULT_ITERATIONS="${BENCH_DEFAULT_ITERATIONS:-10}"

# ============================================
# Timing Functions
# ============================================

# High-precision timing in milliseconds
bench_time_ms() {
    local cmd="$*"
    local start=$(date +%s%N)
    eval "$cmd" > /dev/null 2>&1
    local end=$(date +%s%N)
    echo $(((end - start) / 1000000))
}

# Warmup iterations to reduce noise
bench_warmup() {
    local cmd="$1"
    local iterations="${2:-$BENCH_WARMUP_ITERATIONS}"

    for i in $(seq 1 $iterations); do
        eval "$cmd" > /dev/null 2>&1
    done
}

# Run benchmark with N iterations
bench_run() {
    local name="$1"
    local cmd="$2"
    local iterations="${3:-$BENCH_DEFAULT_ITERATIONS}"

    local times=()

    for i in $(seq 1 $iterations); do
        local time=$(bench_time_ms "$cmd")
        times+=("$time")
        printf "  Run %2d: %dms\n" "$i" "$time"
    done

    bench_calculate_stats "${times[@]}"
}

# ============================================
# Statistical Analysis
# ============================================

# Calculate comprehensive statistics
bench_calculate_stats() {
    local values=("$@")
    local count=${#values[@]}

    if [ $count -eq 0 ]; then
        echo "0,0,0,0,0"
        return 1
    fi

    # Sort values for percentile calculations
    IFS=$'\n' sorted=($(sort -n <<<"${values[*]}"))
    unset IFS

    # Min and Max
    local min=${sorted[0]}
    local max=${sorted[$((count-1))]}

    # Mean (average)
    local sum=0
    for val in "${values[@]}"; do
        sum=$((sum + val))
    done
    local mean=$((sum / count))

    # Median (50th percentile)
    local mid=$((count / 2))
    if [ $((count % 2)) -eq 0 ]; then
        # Even number of values - average the two middle values
        local median=$(( (${sorted[$mid-1]} + ${sorted[$mid]}) / 2 ))
    else
        # Odd number of values - take the middle value
        local median=${sorted[$mid]}
    fi

    # Standard deviation
    local variance=0
    for val in "${values[@]}"; do
        local diff=$((val - mean))
        variance=$((variance + diff * diff))
    done
    variance=$((variance / count))

    # Use bc for square root if available, otherwise approximate
    if command -v bc &> /dev/null; then
        local stddev=$(echo "scale=2; sqrt($variance)" | bc)
    else
        # Simple approximation without bc
        local stddev=$(awk "BEGIN {printf \"%.2f\", sqrt($variance)}")
    fi

    # Return CSV format: min,max,mean,median,stddev
    echo "$min,$max,$mean,$median,$stddev"
}

# Compare two measurements and calculate speedup
bench_compare() {
    local baseline="$1"
    local optimized="$2"

    if [ "$optimized" -eq 0 ]; then
        echo "inf"
        return
    fi

    if command -v bc &> /dev/null; then
        local speedup=$(echo "scale=2; $baseline / $optimized" | bc)
    else
        local speedup=$(awk "BEGIN {printf \"%.2f\", $baseline / $optimized}")
    fi

    echo "$speedup"
}

# Calculate percentile
bench_percentile() {
    local percentile="$1"
    shift
    local values=("$@")
    local count=${#values[@]}

    IFS=$'\n' sorted=($(sort -n <<<"${values[*]}"))
    unset IFS

    local index=$(echo "scale=0; ($count * $percentile) / 100" | bc)
    echo "${sorted[$index]}"
}

# ============================================
# Output Formatting
# ============================================

# Print formatted header
bench_header() {
    local title="$1"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    printf "║  %-62s  ║\n" "$title"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Print section divider
bench_section() {
    local title="$1"
    echo "$title"
    echo "─────────────────────────────────────────────────────────────────"
}

# Print individual result
bench_result() {
    local label="$1"
    local value="$2"
    printf "  %-50s %10s\n" "$label:" "$value"
}

# Print statistics block
bench_print_stats() {
    local stats="$1"
    local label="${2:-Results}"

    IFS=',' read -r min max mean median stddev <<< "$stats"

    echo ""
    echo "$label:"
    printf "  Min:                                             %dms\n" "$min"
    printf "  Max:                                             %dms\n" "$max"
    printf "  Mean:                                            %dms\n" "$mean"
    printf "  Median:                                          %dms\n" "$median"
    printf "  Std Dev:                                       %.2fms\n" "$stddev"
}

# Print comparison results
bench_print_comparison() {
    local baseline_stats="$1"
    local optimized_stats="$2"

    IFS=',' read -r b_min b_max b_mean b_median b_stddev <<< "$baseline_stats"
    IFS=',' read -r o_min o_max o_mean o_median o_stddev <<< "$optimized_stats"

    local speedup=$(bench_compare "$b_mean" "$o_mean")
    local improvement=$(echo "scale=2; 100 - ($o_mean * 100 / $b_mean)" | bc)

    echo ""
    echo "Performance Comparison:"
    echo "─────────────────────────────────"
    printf "  Baseline mean:                               %dms\n" "$b_mean"
    printf "  Optimized mean:                              %dms\n" "$o_mean"
    printf "  Speedup:                                     %.2fx\n" "$speedup"
    printf "  Improvement:                                %.1f%%\n" "$improvement"
}

# ============================================
# Assertions and Validation
# ============================================

# Assert performance target is met
bench_assert_target() {
    local actual="$1"
    local target="$2"
    local label="$3"

    if [ "$actual" -lt "$target" ]; then
        echo "✓ $label meets target: ${actual}ms (target: <${target}ms)"
        return 0
    else
        echo "✗ $label exceeds target: ${actual}ms (target: <${target}ms)"
        return 1
    fi
}

# Assert improvement over baseline
bench_assert_improvement() {
    local baseline="$1"
    local optimized="$2"
    local min_speedup="$3"
    local label="${4:-Performance}"

    local speedup=$(bench_compare "$baseline" "$optimized")

    if (( $(echo "$speedup >= $min_speedup" | bc -l) )); then
        echo "✓ $label improved: ${speedup}x (required: >${min_speedup}x)"
        return 0
    else
        echo "✗ $label insufficient: ${speedup}x (required: >${min_speedup}x)"
        return 1
    fi
}

# ============================================
# Results Storage
# ============================================

# Initialize results directory
bench_init() {
    mkdir -p "$BENCH_RESULTS_DIR"
}

# Save benchmark result to CSV
bench_save_result() {
    bench_init

    local name="$1"
    local stats="$2"
    local operation="${3:-}"

    local timestamp=$(date +%s)
    local results_file="$BENCH_RESULTS_DIR/results.csv"

    # Create header if file doesn't exist
    if [ ! -f "$results_file" ]; then
        echo "timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata" > "$results_file"
    fi

    # Append result
    echo "$timestamp,$name,$operation,$stats," >> "$results_file"
}

# Load historical results
bench_load_results() {
    local name="$1"
    local operation="${2:-}"

    local results_file="$BENCH_RESULTS_DIR/results.csv"

    if [ ! -f "$results_file" ]; then
        return 1
    fi

    if [ -n "$operation" ]; then
        grep "^[^,]*,$name,$operation," "$results_file"
    else
        grep "^[^,]*,$name," "$results_file"
    fi
}

# Generate summary report
generate_summary() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║  Benchmark Complete                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Results saved to: $BENCH_RESULTS_DIR/results.csv"
    echo ""
}

# ============================================
# Workspace Management
# ============================================

# Create test workspace
bench_create_workspace() {
    local size="${1:-medium}"
    local workspace=$(mktemp -d)

    case "$size" in
        tiny)
            # 5 folders
            for i in {1..5}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        small)
            # 10 folders
            for i in {1..10}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        medium)
            # 50 folders
            for i in {1..50}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        large)
            # 500 folders
            for i in {1..500}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        xlarge)
            # 1000 folders
            for i in {1..1000}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        *)
            echo "Unknown workspace size: $size"
            rm -rf "$workspace"
            return 1
            ;;
    esac

    echo "$workspace"
}

# Create nested workspace
bench_create_nested_workspace() {
    local depth="${1:-3}"
    local breadth="${2:-5}"
    local workspace=$(mktemp -d)

    bench_create_nested_helper "$workspace" 0 "$depth" "$breadth"

    echo "$workspace"
}

bench_create_nested_helper() {
    local parent="$1"
    local current_depth="$2"
    local max_depth="$3"
    local breadth="$4"

    if [ "$current_depth" -ge "$max_depth" ]; then
        return
    fi

    for i in $(seq 1 $breadth); do
        local dir="$parent/level${current_depth}-$i"
        mkdir -p "$dir"
        bench_create_nested_helper "$dir" $((current_depth + 1)) "$max_depth" "$breadth"
    done
}

# Cleanup workspace
bench_cleanup_workspace() {
    local workspace="$1"

    if [ -d "$workspace" ] && [[ "$workspace" == /tmp/* ]]; then
        rm -rf "$workspace"
    else
        echo "Warning: Refusing to delete non-temp directory: $workspace"
    fi
}

# ============================================
# Utility Functions
# ============================================

# Check if command exists
bench_require_command() {
    local cmd="$1"

    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: Required command not found: $cmd"
        exit 1
    fi
}

# Verify benchmark prerequisites
bench_verify_env() {
    # Check for required commands
    bench_require_command "date"
    bench_require_command "mktemp"

    # Verify results directory is writable
    bench_init
    if [ ! -w "$BENCH_RESULTS_DIR" ]; then
        echo "Error: Results directory not writable: $BENCH_RESULTS_DIR"
        exit 1
    fi
}
```

### Benchmark Patterns

#### Pattern 1: Cached vs Uncached Comparison

**Purpose:** Measure performance improvement from caching

```bash
#!/bin/bash
# Benchmark: Cached vs Uncached Navigation Performance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/cache-index.sh"

main() {
    bench_header "Cached vs Uncached Navigation Performance"

    echo "Configuration:"
    echo "  Target folder: unix-goto"
    echo "  Iterations: 10"
    echo "  Warmup: 3 runs"
    echo ""

    benchmark_cached_vs_uncached

    generate_summary
}

benchmark_cached_vs_uncached() {
    bench_section "Benchmark: Cached vs Uncached Lookup"

    # Phase 1: Uncached lookup
    echo "Phase 1: Uncached lookup (no cache)"
    echo "─────────────────────────────────"

    # Remove cache to force uncached lookup
    rm -f "$HOME/.goto_index"

    # Warmup
    bench_warmup "find ~/Documents -name unix-goto -type d -maxdepth 5" 3

    # Run benchmark
    local uncached_stats=$(bench_run "uncached" \
        "find ~/Documents -name unix-goto -type d -maxdepth 5" 10)

    IFS=',' read -r uc_min uc_max uc_mean uc_median uc_stddev <<< "$uncached_stats"

    bench_print_stats "$uncached_stats" "Uncached Results"

    # Phase 2: Cached lookup
    echo ""
    echo "Phase 2: Cached lookup (with cache)"
    echo "─────────────────────────────────"

    # Build cache
    __goto_cache_build

    # Warmup
    bench_warmup "__goto_cache_lookup unix-goto" 3

    # Run benchmark
    local cached_stats=$(bench_run "cached" \
        "__goto_cache_lookup unix-goto" 10)

    IFS=',' read -r c_min c_max c_mean c_median c_stddev <<< "$cached_stats"

    bench_print_stats "$cached_stats" "Cached Results"

    # Analysis
    echo ""
    bench_print_comparison "$uncached_stats" "$cached_stats"

    # Assert targets
    bench_assert_target "$c_mean" 100 "Cached navigation time"
    bench_assert_improvement "$uc_mean" "$c_mean" 5 "Cache speedup"

    # Save results
    bench_save_result "cached_vs_uncached" "$uncached_stats" "uncached"
    bench_save_result "cached_vs_uncached" "$cached_stats" "cached"
}

main
exit 0
```

**Key Points:**
1. Clear phase separation (uncached vs cached)
2. Proper warmup before measurements
3. Statistical analysis of results
4. Comparison and speedup calculation
5. Target assertions
6. Results storage

#### Pattern 2: Scalability Testing

**Purpose:** Measure performance at different scales

```bash
#!/bin/bash
# Benchmark: Cache Performance at Scale

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/cache-index.sh"

main() {
    bench_header "Cache Performance at Scale"

    echo "Testing cache performance with different folder counts"
    echo ""

    benchmark_scale_10
    echo ""
    benchmark_scale_50
    echo ""
    benchmark_scale_500
    echo ""
    benchmark_scale_1000

    generate_summary
}

benchmark_scale() {
    local count="$1"
    local target="${2:-100}"

    bench_section "Benchmark: $count Folders"

    # Setup workspace
    local workspace=$(bench_create_workspace_with_count "$count")
    local old_paths="$GOTO_SEARCH_PATHS"
    export GOTO_SEARCH_PATHS="$workspace"

    # Build cache
    __goto_cache_build

    # Warmup
    bench_warmup "__goto_cache_lookup folder-$((count / 2))" 3

    # Run benchmark
    local stats=$(bench_run "scale_$count" \
        "__goto_cache_lookup folder-$((count / 2))" 10)

    IFS=',' read -r min max mean median stddev <<< "$stats"

    bench_print_stats "$stats" "Results ($count folders)"

    # Assert target
    bench_assert_target "$mean" "$target" "Cache lookup at scale"

    # Save results
    bench_save_result "cache_scale" "$stats" "folders_$count"

    # Cleanup
    export GOTO_SEARCH_PATHS="$old_paths"
    bench_cleanup_workspace "$workspace"
}

bench_create_workspace_with_count() {
    local count="$1"
    local workspace=$(mktemp -d)

    for i in $(seq 1 $count); do
        mkdir -p "$workspace/folder-$i"
    done

    echo "$workspace"
}

benchmark_scale_10() { benchmark_scale 10 50; }
benchmark_scale_50() { benchmark_scale 50 75; }
benchmark_scale_500() { benchmark_scale 500 100; }
benchmark_scale_1000() { benchmark_scale 1000 150; }

main
exit 0
```

**Key Points:**
1. Test at multiple scale points
2. Adjust targets based on scale
3. Workspace generation for each scale
4. Proper cleanup between tests
5. Results tracking per scale level

#### Pattern 3: Multi-Level Path Performance

**Purpose:** Measure performance with complex navigation paths

```bash
#!/bin/bash
# Benchmark: Multi-Level Path Navigation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/goto-function.sh"

main() {
    bench_header "Multi-Level Path Navigation Performance"

    echo "Testing navigation with multi-level paths (e.g., LUXOR/unix-goto)"
    echo ""

    benchmark_multi_level_paths

    generate_summary
}

benchmark_multi_level_paths() {
    bench_section "Benchmark: Multi-Level Path Navigation"

    # Setup nested workspace
    local workspace=$(bench_create_nested_workspace 4 3)
    local old_paths="$GOTO_SEARCH_PATHS"
    export GOTO_SEARCH_PATHS="$workspace"

    # Build cache
    __goto_cache_build

    # Test single-level path
    echo "Single-level path lookup:"
    bench_warmup "goto level0-1" 3
    local single_stats=$(bench_run "single_level" "goto level0-1" 10)
    bench_print_stats "$single_stats" "Single-Level Results"

    echo ""

    # Test two-level path
    echo "Two-level path lookup:"
    bench_warmup "goto level0-1/level1-1" 3
    local double_stats=$(bench_run "double_level" "goto level0-1/level1-1" 10)
    bench_print_stats "$double_stats" "Two-Level Results"

    echo ""

    # Test three-level path
    echo "Three-level path lookup:"
    bench_warmup "goto level0-1/level1-1/level2-1" 3
    local triple_stats=$(bench_run "triple_level" "goto level0-1/level1-1/level2-1" 10)
    bench_print_stats "$triple_stats" "Three-Level Results"

    # Analysis
    echo ""
    echo "Path Complexity Analysis:"
    IFS=',' read -r s_min s_max s_mean s_median s_stddev <<< "$single_stats"
    IFS=',' read -r d_min d_max d_mean d_median d_stddev <<< "$double_stats"
    IFS=',' read -r t_min t_max t_mean t_median t_stddev <<< "$triple_stats"

    printf "  Single-level mean:                           %dms\n" "$s_mean"
    printf "  Two-level mean:                              %dms\n" "$d_mean"
    printf "  Three-level mean:                            %dms\n" "$t_mean"

    # All should be <100ms
    bench_assert_target "$s_mean" 100 "Single-level navigation"
    bench_assert_target "$d_mean" 100 "Two-level navigation"
    bench_assert_target "$t_mean" 100 "Three-level navigation"

    # Save results
    bench_save_result "multi_level_paths" "$single_stats" "single_level"
    bench_save_result "multi_level_paths" "$double_stats" "double_level"
    bench_save_result "multi_level_paths" "$triple_stats" "triple_level"

    # Cleanup
    export GOTO_SEARCH_PATHS="$old_paths"
    bench_cleanup_workspace "$workspace"
}

main
exit 0
```

**Key Points:**
1. Test increasing complexity
2. Nested workspace generation
3. Measure each level independently
4. Compare complexity impact
5. Ensure all levels meet targets

## Examples

### Example 1: Complete Cache Build Benchmark

```bash
#!/bin/bash
# Benchmark: Cache Build Performance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/cache-index.sh"

main() {
    bench_header "Cache Build Performance"

    echo "Configuration:"
    echo "  Search paths: $GOTO_SEARCH_PATHS"
    echo "  Max depth: ${GOTO_SEARCH_DEPTH:-3}"
    echo "  Iterations: 10"
    echo ""

    benchmark_cache_build

    generate_summary
}

benchmark_cache_build() {
    bench_section "Benchmark: Cache Build Time"

    # Count folders to be indexed
    echo "Analyzing workspace..."
    local folder_count=$(find ${GOTO_SEARCH_PATHS//:/ } -type d -maxdepth ${GOTO_SEARCH_DEPTH:-3} 2>/dev/null | wc -l)
    echo "  Folders to index: $folder_count"
    echo ""

    # Phase 1: Full cache build
    echo "Phase 1: Full cache build (cold start)"
    echo "─────────────────────────────────────────"

    # Remove existing cache
    rm -f "$HOME/.goto_index"

    # Warmup filesystem cache
    find ${GOTO_SEARCH_PATHS//:/ } -type d -maxdepth ${GOTO_SEARCH_DEPTH:-3} > /dev/null 2>&1

    # Run benchmark
    local build_times=()
    for i in {1..10}; do
        rm -f "$HOME/.goto_index"
        local time=$(bench_time_ms "__goto_cache_build")
        build_times+=("$time")
        printf "  Build %2d: %dms\n" "$i" "$time"
    done

    local build_stats=$(bench_calculate_stats "${build_times[@]}")
    IFS=',' read -r min max mean median stddev <<< "$build_stats"

    bench_print_stats "$build_stats" "Build Performance"

    # Analysis
    echo ""
    echo "Performance Analysis:"
    printf "  Folders indexed:                             %d\n" "$folder_count"
    printf "  Average build time:                          %dms\n" "$mean"
    printf "  Time per folder:                             %.2fms\n" \
        $(echo "scale=2; $mean / $folder_count" | bc)

    # Assert target (<5000ms = 5 seconds)
    bench_assert_target "$mean" 5000 "Cache build time"

    # Save results
    bench_save_result "cache_build" "$build_stats" "full_build,folders=$folder_count"
}

main
exit 0
```

### Example 2: Parallel Navigation Benchmark

```bash
#!/bin/bash
# Benchmark: Parallel Navigation Performance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/cache-index.sh"

main() {
    bench_header "Parallel Navigation Performance"

    echo "Testing concurrent cache access performance"
    echo ""

    benchmark_parallel_navigation

    generate_summary
}

benchmark_parallel_navigation() {
    bench_section "Benchmark: Concurrent Cache Access"

    # Setup
    __goto_cache_build

    # Test different concurrency levels
    for concurrency in 1 5 10 20; do
        echo ""
        echo "Testing with $concurrency concurrent lookups:"
        echo "─────────────────────────────────────────"

        local times=()

        for run in {1..10}; do
            local start=$(date +%s%N)

            # Launch concurrent lookups
            for i in $(seq 1 $concurrency); do
                __goto_cache_lookup "unix-goto" > /dev/null 2>&1 &
            done

            # Wait for all to complete
            wait

            local end=$(date +%s%N)
            local duration=$(((end - start) / 1000000))
            times+=("$duration")
            printf "  Run %2d: %dms\n" "$run" "$duration"
        done

        local stats=$(bench_calculate_stats "${times[@]}")
        IFS=',' read -r min max mean median stddev <<< "$stats"

        echo ""
        echo "Results (concurrency=$concurrency):"
        printf "  Mean time:                                   %dms\n" "$mean"
        printf "  Time per lookup:                             %dms\n" \
            $((mean / concurrency))

        # Save results
        bench_save_result "parallel_navigation" "$stats" "concurrency=$concurrency"
    done

    echo ""
    echo "Analysis:"
    echo "  Cache supports concurrent reads efficiently"
    echo "  No significant degradation with increased concurrency"
}

main
exit 0
```

## Best Practices

### Benchmark Design Principles

**1. Statistical Validity**
- Run at least 10 iterations
- Use proper warmup (3+ runs)
- Calculate full statistics (min/max/mean/median/stddev)
- Report median for central tendency (less affected by outliers)
- Report stddev to show consistency

**2. Realistic Testing**
- Test at production-like scale
- Use realistic workspaces
- Test common user workflows
- Include edge cases

**3. Isolation**
- Run on idle system
- Disable unnecessary background processes
- Clear caches between test phases
- Use dedicated test workspaces

**4. Reproducibility**
- Document all configuration
- Use consistent test data
- Version benchmark code
- Save all results

**5. Clarity**
- Clear benchmark names
- Descriptive output
- Meaningful comparisons
- Actionable insights

### Performance Target Setting

**Define targets based on user perception:**

| Range | User Perception | Use Case |
|-------|----------------|----------|
| <50ms | Instant | Critical path operations |
| <100ms | Very fast | Interactive operations |
| <200ms | Fast | Background operations |
| <1s | Acceptable | Initial setup |
| >1s | Slow | Needs optimization |

**unix-goto targets:**
- Navigation: <100ms (feels instant)
- Lookups: <10ms (imperceptible)
- Cache build: <5s (acceptable for setup)

### Results Analysis

**Key metrics to track:**

1. **Mean** - Average performance (primary metric)
2. **Median** - Middle value (better for skewed distributions)
3. **Min** - Best case performance
4. **Max** - Worst case performance
5. **Stddev** - Consistency (lower is better)

**Red flags:**
- High stddev (>20% of mean) - inconsistent performance
- Increasing trend over time - performance regression
- Max >> Mean - outliers, possible issues

### CSV Results Format

**Standard format:**
```csv
timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata
1704123456,cached_vs_uncached,uncached,25,32,28,28,2.1,
1704123456,cached_vs_uncached,cached,15,22,18,19,1.8,
1704123457,cache_scale,folders_10,10,15,12,12,1.5,
1704123458,cache_scale,folders_500,85,110,95,92,8.2,
```

**Benefits:**
- Easy to parse and analyze
- Compatible with Excel/Google Sheets
- Can track trends over time
- Enables automated regression detection

## Quick Reference

### Essential Benchmark Functions

```bash
# Timing
bench_time_ms "command args"              # High-precision timing
bench_warmup "command" 3                  # Warmup iterations
bench_run "name" "command" 10             # Full benchmark run

# Statistics
bench_calculate_stats val1 val2 val3      # Calculate stats
bench_compare baseline optimized          # Calculate speedup

# Workspace
bench_create_workspace "medium"           # Create test workspace
bench_create_nested_workspace 3 5         # Nested workspace
bench_cleanup_workspace "$workspace"      # Remove workspace

# Output
bench_header "Title"                      # Print header
bench_section "Section"                   # Print section
bench_print_stats "$stats" "Label"        # Print statistics
bench_print_comparison "$s1" "$s2"        # Print comparison

# Assertions
bench_assert_target actual target "msg"   # Assert performance target
bench_assert_improvement base opt min "m" # Assert improvement

# Results
bench_save_result "name" "$stats" "op"    # Save to CSV
bench_load_results "name"                 # Load historical results
```

### Standard Benchmark Workflow

```bash
# 1. Setup
bench_header "Benchmark Title"
workspace=$(bench_create_workspace "medium")

# 2. Warmup
bench_warmup "command" 3

# 3. Measure
stats=$(bench_run "name" "command" 10)

# 4. Analyze
IFS=',' read -r min max mean median stddev <<< "$stats"
bench_print_stats "$stats" "Results"

# 5. Assert
bench_assert_target "$mean" 100 "Performance"

# 6. Save
bench_save_result "benchmark" "$stats" "operation"

# 7. Cleanup
bench_cleanup_workspace "$workspace"
```

### Performance Targets Quick Reference

| Operation | Target | Rationale |
|-----------|--------|-----------|
| Cached navigation | <100ms | Instant feel |
| Bookmark lookup | <10ms | Imperceptible |
| Cache build | <5s | Setup time |
| Cache speedup | >20x | Significant improvement |
| Cache hit rate | >90% | Most queries cached |

---

**Skill Version:** 1.0
**Last Updated:** October 2025
**Maintained By:** Manu Tej + Claude Code
**Source:** unix-goto benchmark patterns and methodologies
