---
description: Monitor context window usage and optimize token consumption
allowed-tools: Read(**), Grep(**), Bash(*)
---

# /context-budget

Monitor context window usage in real-time and optimize agent invocations for maximum efficiency.

## Usage

```bash
# Show current usage
/context-budget

# Analyze optimization opportunities
/context-budget --analyze

# Set budget limit
/context-budget --set-limit 150000

# Per-agent usage
/context-budget --agent <name>

# Historical tracking
/context-budget --history
/context-budget --history --week
/context-budget --history --month

# Reset session tracking
/context-budget --reset
```

## Arguments

- No arguments: Show current session usage
- `--analyze`: Identify optimization opportunities
- `--set-limit <tokens>`: Set session token budget
- `--agent <name>`: Show usage for specific agent
- `--history`: Show historical usage patterns
- `--history --week`: Last 7 days
- `--history --month`: Last 30 days
- `--reset`: Reset current session tracking

## What It Does

The `/context-budget` command tracks token consumption and provides actionable optimization recommendations.

### Current Usage Mode
1. Calculates tokens used in current conversation session
2. Breaks down by activity type:
   - Agent invocations (Task tool calls)
   - File reading (Read tool usage)
   - Command output (Bash, Grep, etc.)
   - Conversation messages
3. Shows remaining budget from configured limit
4. Warns if approaching threshold (default: 75%)
5. Lists top token consumers with details
6. Provides immediate optimization suggestions

### Analysis Mode
1. Reviews recent operations for inefficiency patterns
2. Identifies high-cost operations:
   - Redundant file reads (same file multiple times)
   - Inefficient agent invocations (poor context setup)
   - Missing result caching opportunities
   - Overly broad file searches
3. Simulates potential token savings from optimizations
4. Provides specific recommendations with code examples
5. Calculates percentage reduction achievable

### Per-Agent Tracking
1. Analyzes specific agent's token consumption history
2. Compares to agent baseline averages
3. Identifies outlier invocations (unusually high/low usage)
4. Shows efficiency trends over time
5. Suggests agent-specific optimization approaches
6. Displays best practices for that agent

### Historical Analysis
1. Aggregates usage data from session logs
2. Shows daily/weekly/monthly trends
3. Identifies usage patterns and spikes
4. Highlights anomalies requiring attention
5. Provides comparative analysis over time
6. Suggests optimal session management strategies

## Examples

### Example 1: Current Usage (Healthy)
```bash
/context-budget
```

**Output**:
```
💰 Context Window Budget

Current Session:
  Used:      47,234 tokens  │████████        │ 24%
  Remaining: 152,766 tokens
  Limit:     200,000 tokens (system default)
  Model:     claude-sonnet-4-5

Breakdown:
  Agent invocations:   28,456 tokens (60%)
  File reading:        12,345 tokens (26%)
  Command output:       4,123 tokens (9%)
  Conversation:         2,310 tokens (5%)

Status: ✅ Healthy (well under budget)

Top Token Consumers:
1. deep-researcher       12,345 tokens (2 invocations)
2. code-craftsman         8,234 tokens (3 invocations)
3. practical-programmer   7,877 tokens (2 invocations)

Recent Operations (Last 5):
  15 min ago: deep-researcher (12,345 tokens)
  25 min ago: code-craftsman (4,567 tokens)
  40 min ago: Read src/large-file.ts (3,456 tokens)
  50 min ago: code-craftsman (3,667 tokens)
  1 hr ago: Read multiple files (8,889 tokens)

💡 Tips:
  • You have plenty of budget for complex tasks
  • Consider using /orch for multi-agent workflows
  • Current efficiency: 94% (excellent)
```

### Example 2: Approaching Limit (Warning)
```bash
/context-budget
```

**Output**:
```
💰 Context Window Budget

Current Session:
  Used:      155,234 tokens  │████████████████│ 78%
  Remaining:  44,766 tokens
  Limit:     200,000 tokens
  Model:     claude-sonnet-4-5

⚠️  Status: CAUTION (approaching limit)

Breakdown:
  Agent invocations:   98,567 tokens (63%)
  File reading:        42,345 tokens (27%)
  Command output:      10,234 tokens (7%)
  Conversation:         4,088 tokens (3%)

⚠️  High-Cost Recent Operations:
  • deep-researcher (45K tokens) - Consider phased research
  • Multiple large file reads (32K tokens) - Use targeted reading
  • mercurio-orchestrator (38K tokens) - Expected for complexity

🚨 Recommendations:
  1. Start new session for next complex task
  2. Use /orch --optimize-context for large operations
  3. Apply targeted file reads (offset/limit parameters)
  4. Review loaded files - many large files in memory

🔧 Quick Actions:
  /context-budget --analyze      # Detailed optimization analysis
  /context-budget --reset        # Start fresh tracking
  /orch "<task>" --optimize-context  # Optimize next task
```

### Example 3: Optimization Analysis
```bash
/context-budget --analyze
```

**Output**:
```
🔍 Context Optimization Analysis

Current Efficiency: 67% (Good, improvable)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Optimization Opportunity #1: File Reading Patterns
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Potential Savings: 15,234 tokens (32% of file reads)

Issue: Reading entire files when only sections needed

Current Pattern Detected:
  ❌ Read("src/components/LargeComponent.tsx")  # 12,345 tokens
  ❌ Read("lib/utils.ts")  # 8,234 tokens
  ❌ Read("config/settings.json")  # 4,567 tokens

Optimized Approach:
  ✅ Grep("ComponentName", glob="**/*.tsx", output_mode="content", -n=true)
     → Identify relevant files first
  ✅ Read("src/components/LargeComponent.tsx", offset=100, limit=50)
     → Read only needed sections
  Savings: ~9,000 tokens per large file (73% reduction)

Specific Files to Optimize:
  • src/components/LargeComponent.tsx: 12,345 → 3,400 tokens
  • lib/utils.ts: 8,234 → 2,100 tokens
  • config/settings.json: 4,567 → 1,200 tokens

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Optimization Opportunity #2: Agent Invocation Efficiency
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Potential Savings: 12,456 tokens (26% of agent costs)

Issue: Sequential agents re-reading same context

Current Pattern Detected:
  ❌ Task(agent="code-craftsman") reads 15 files
  ❌ Task(agent="practical-programmer") reads same 15 files
  ❌ Task(agent="test-engineer") reads same 15 files
  Total: 45K tokens for redundant reads

Optimized Approach:
  ✅ Use /orch to coordinate agents with shared context
  ✅ Enable result caching between agents
  ✅ Pass analysis results explicitly
  Savings: ~12,000 tokens (27% reduction)

Example:
  Instead of:
    Task("refactor code", subagent_type="code-craftsman")
    Task("add tests", subagent_type="test-engineer")
    Task("document", subagent_type="docs-generator")

  Use:
    /orch "refactor code → add tests → document" --optimize-context

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Optimization Opportunity #3: Command Output Volume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Potential Savings: 3,200 tokens (31% of command output)

Issue: Verbose command output consuming tokens

Current Pattern Detected:
  ❌ Grep without head_limit → 500 results (4,567 tokens)
  ❌ Bash git log without limits → full history (2,345 tokens)

Optimized Approach:
  ✅ Grep with head_limit=20 → Top results only
  ✅ Bash git log -10 → Recent commits only
  Savings: ~3,200 tokens

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Total Optimization Potential:
  Current usage: 155,234 tokens
  After optimization: ~124,344 tokens
  Total savings: 30,890 tokens (20% reduction)

🎯 Priority Actions (Immediate Impact):
  1. ✅ Use Read with offset/limit for large files
  2. ✅ Add head_limit to Grep operations
  3. ✅ Use /orch for multi-agent coordination
  4. ✅ Limit command output verbosity

💡 Quick Wins (Easy to implement):
  • Add offset/limit to Read: Save ~10K tokens
  • Use Grep before Read: Save ~5K tokens
  • Limit Bash output: Save ~3K tokens

🔧 Apply Suggestions:
  These optimizations can be applied to your next operations.
  Use /orch --optimize-context to automatically apply patterns.
```

### Example 4: Per-Agent Analysis
```bash
/context-budget --agent code-craftsman
```

**Output**:
```
📊 Token Analysis: code-craftsman

Recent Invocations (Last 10):

┌─────┬──────────────┬─────────┬────────┬────────────┬──────────────────┐
│ #   │ Time         │ Tokens  │ Time   │ Efficiency │ Task Summary     │
├─────┼──────────────┼─────────┼────────┼────────────┼──────────────────┤
│ 1   │ 2 hours ago  │ 18,234  │ 12 min │ 94% ✅     │ Implement auth   │
│ 2   │ 4 hours ago  │ 24,567  │ 18 min │ 82% ⚠️     │ Refactor DB      │
│     │              │         │        │ (high)     │ (loaded 30 files)│
│ 3   │ 1 day ago    │ 15,234  │ 10 min │ 107% ⭐    │ Add validation   │
│     │              │         │        │ (excellent)│ (targeted)       │
│ 4   │ 1 day ago    │ 19,456  │ 13 min │ 96% ✅     │ Create API       │
│ 5   │ 2 days ago   │ 17,890  │ 11 min │ 98% ✅     │ Build form       │
└─────┴──────────────┴─────────┴────────┴────────────┴──────────────────┘

Aggregate Statistics:
  Total invocations: 15 (last 30 days)
  Average tokens: 18,456
  Median tokens: 17,234
  Best: 12,345 tokens (targeted validation)
  Worst: 28,567 tokens (broad refactoring)
  Average time: 12 minutes

Efficiency Score: 94% (Excellent)

Efficiency Trends:
  Last week:    18,456 avg tokens  ████████████████████│
  Last month:   19,234 avg tokens  ████████████████████│ 96%
  Improvement:  4% ✅ (trending more efficient)

Token Distribution:
  10K-15K:  20% │████                │ Focused tasks
  15K-20K:  60% │████████████        │ ← Most common (optimal)
  20K-25K:  15% │███                 │ Moderate scope
  25K+:      5% │█                   │ ← Outliers (review these)

📁 File Loading Analysis:
  Average files loaded: 8 per invocation
  Optimal range: 3-10 files
  Recommendation: ✅ Good file scoping

  Outliers requiring review:
  • Invocation #2: 30 files loaded (consider phasing)

🎯 Best Practices Observed:
  ✓ Specific file paths provided (not "refactor everything")
  ✓ Clear scope and requirements
  ✓ Focused on 1-3 files per task (most efficient)
  ✓ Targeted requirements vs broad mandates

⚠️  Patterns to Avoid:
  ✗ "Refactor entire codebase" → Very high tokens
  ✗ Loading 20+ files unnecessarily
  ✗ Vague requirements leading to exploration

💡 Optimization Tips for code-craftsman:
  1. Specify exact files: "Refactor src/auth.ts" > "Refactor auth module"
  2. Use Grep first to identify relevant code sections
  3. Break large refactorings into focused phases
  4. Provide clear acceptance criteria upfront
  5. Limit scope to 5-10 files per invocation

📈 Suggested Workflow:
  Instead of: Single large refactoring (28K tokens)
  Use: 3 focused phases (3 × 10K = 30K total, but clearer results)
```

### Example 5: Historical Trends
```bash
/context-budget --history --week
```

**Output**:
```
📈 Token Usage History (Last 7 Days)

Daily Breakdown:
┌────────────┬────────┬───────────┬──────────┬─────────┬─────────┐
│ Date       │ Total  │ Agents    │ Files    │ Peak    │ Status  │
├────────────┼────────┼───────────┼──────────┼─────────┼─────────┤
│ 2025-10-12 │ 155K   │ 98K (63%) │ 42K (27%)│ 45K     │ ⚠️       │
│ 2025-10-11 │ 142K   │ 89K (63%) │ 38K (27%)│ 38K     │ ✅      │
│ 2025-10-10 │ 98K    │ 62K (63%) │ 28K (29%)│ 28K     │ ✅      │
│ 2025-10-09 │ 134K   │ 87K (65%) │ 35K (26%)│ 42K     │ ✅      │
│ 2025-10-08 │ 167K ⚠️│ 108K (65%)│ 45K (27%)│ 52K ⚠️  │ ⚠️       │
│ 2025-10-07 │ 123K   │ 78K (63%) │ 32K (26%)│ 34K     │ ✅      │
│ 2025-10-06 │ 109K   │ 71K (65%) │ 29K (27%)│ 29K     │ ✅      │
└────────────┴────────┴───────────┴──────────┴─────────┴─────────┘

Week Summary:
  Total: 928K tokens
  Daily Average: 133K tokens
  Trend: ↗️ +8% vs previous week
  Efficiency: 92% (good)

Peak Usage Days:
  1. Oct 8 (167K) - Complex research project
  2. Oct 12 (155K) - Multi-agent orchestration
  3. Oct 11 (142K) - Documentation generation

Efficiency Metrics:
  Avg tokens per agent: 18,567
  Avg tokens per file read: 3,456
  Agent invocations: 47 total
  Efficiency vs baseline: 94% (Good)

📊 Weekly Patterns Detected:
  ✓ Higher usage mid-week (Tue-Thu)
  ✓ Research tasks consume more tokens
  ✓ Morning sessions 15% more efficient
  ⚠️  File reads increased 12% this week

💡 Recommendations:
  1. Schedule research-heavy tasks early in new sessions
  2. Monitor Oct 8 pattern - approached limit
  3. Consider /orch --optimize-context for large projects
  4. Review file reading patterns - increasing trend

🎯 Agent Usage Distribution:
  code-craftsman:        23 invocations (49%)
  deep-researcher:        8 invocations (17%)
  practical-programmer:   7 invocations (15%)
  test-engineer:          5 invocations (11%)
  Others:                 4 invocations (8%)
```

## Configuration

Default settings in `.claude/context-budget-config.yaml`:
```yaml
limits:
  default_session_limit: 200000  # sonnet-4-5 max
  warning_threshold: 0.75  # 75% = warning
  critical_threshold: 0.90  # 90% = critical alert

tracking:
  enable_logging: true
  log_file: .claude/logs/token-usage.json
  track_per_agent: true
  track_file_reads: true
  track_commands: true
  history_retention_days: 90

optimization:
  auto_suggest: true
  suggest_threshold: 50000  # Start suggesting at 50K
  enable_recommendations: true
  show_savings_estimates: true

display:
  show_breakdown: true
  show_top_consumers: 5
  use_progress_bars: true
  color_coding: true
  emoji_indicators: true
```

## Integration Points

### With /orch
- Monitors orchestration token costs automatically
- Applies --optimize-context when approaching limit
- Tracks multi-agent workflow efficiency
- Provides optimization feedback

### With /crew
- Supplies per-agent token statistics
- Helps choose efficient agents for tasks
- Identifies resource-intensive agents
- Feeds efficiency data to agent recommendations

### With /wflw
- Tracks workflow token consumption
- Validates workflow estimates vs actual usage
- Suggests workflow optimization opportunities
- Updates workflow YAML with actual costs

## Tips for Best Results

1. **Check Before Large Tasks**: Run before complex operations
2. **Use Analysis Regularly**: Run --analyze when usage seems high
3. **Set Realistic Limits**: Adjust based on typical patterns
4. **Monitor Trends**: Review --history weekly
5. **Optimize Proactively**: Don't wait until limit reached
6. **Learn Patterns**: Study efficient vs inefficient operations
7. **Use Per-Agent**: Check specific agents causing high usage

## Related Commands

- `/orch --optimize-context` - Apply optimizations to orchestration
- `/crew --stats` - Agent efficiency statistics
- `/aprof <agent>` - Deep agent performance analysis
- `/wflw` - Workflow token tracking

## Version History

- v1.0: Initial token tracking
- v1.1: Optimization analysis
- v1.2: Per-agent tracking
- v1.3: Historical trends
- v1.4: Auto-optimization suggestions

## Philosophy

Context windows are precious resources that enable powerful AI capabilities. The `/context-budget` command provides visibility and control, ensuring efficient token usage while maintaining output quality. Think of it as your resource advisor—monitoring consumption, identifying waste, and helping maximize value from every token spent.
