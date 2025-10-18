---
description: Flexible loop construct for repeating commands over items
args:
  - name: source
    description: Iteration source (glob, list, range, file, command output)
  - name: command_template
    description: Command to execute with {} placeholder for substitution
  - name: flags
    description: Optional --help, --parallel, --continue-on-error, --var=name
allowed-tools: Read(**), Bash(*), Glob(*), Task(*), TodoWrite
---

# /foreach

Execute command for each item in: $ARGUMENTS

## Your Task

Parse the iteration source and command template, then execute the command for each item.

### 1. Parse Arguments

Extract from $ARGUMENTS:
- **Source type**: Auto-detect from pattern
  - Glob pattern: `*.ts`, `src/**/*.js`
  - Numeric range: `1..10`, `0..100`
  - List: Comma-separated values
  - File: `@filename.txt` (one item per line)
  - Command: `$(command)` or backticks
- **Command template**: String with `{}` placeholder(s)
- **Flags**: `--parallel`, `--continue-on-error`, `--var=custom`

### 2. Expand Source to Items

Based on source type:
- **Glob**: Use Glob tool to find matching files
- **Range**: Generate numeric sequence
- **List**: Split on commas or whitespace
- **File**: Read file and split on newlines
- **Command**: Execute command and capture output lines

### 3. Execute Command for Each Item

For each item in the expanded list:
1. Substitute `{}` (or custom var) with item value
2. Parse command type:
   - Slash command: `/command-name args`
   - Task invocation: `Task("prompt", agent)`
   - Bash command: `Bash(command)`
   - Natural language: Treat as instruction
3. Execute command (sequential or parallel based on flags)
4. Track results and errors
5. Continue or stop based on `--continue-on-error` flag

### 4. Handle Flags

Parse from $ARGUMENTS:
- `--help`: Show usage guide and examples (don't execute)
- `--parallel`: Execute commands concurrently (faster for independent tasks)
- `--continue-on-error`: Don't stop on first failure
- `--var=name`: Use custom placeholder like `{name}` instead of `{}`
- Default: Sequential execution, stop on error

**If `--help` flag detected:**
Show comprehensive help text:
```
📖 /foreach - Flexible Loop Construct

USAGE:
  /foreach <source> "<command-template>" [flags]

SOURCE TYPES:
  Glob pattern    *.ts, src/**/*.js
  Numeric range   1..10, 0..100
  List           item1,item2,item3
  File           @urls.txt (one per line)
  Command        $(git diff --name-only)

COMMAND TEMPLATE:
  Use {} as placeholder for each item
  Examples: "analyze {}", "/yt {} -d", "Task('review {}', code-craftsman)"

FLAGS:
  --help                Show this help message
  --parallel            Execute commands concurrently
  --continue-on-error   Don't stop on first failure
  --var=name           Use custom placeholder {name}

EXAMPLES:
  # Process all TypeScript files
  /foreach "src/**/*.ts" "analyze code in {}"

  # Numeric batch processing
  /foreach "1..10" "process batch {}"

  # Parallel video processing
  /foreach "*.mp4" "/yt {} -d" --parallel

  # Read from file
  /foreach "@urls.txt" "/yt {} -a"

  # Continue on errors
  /foreach "tests/*.ts" "Bash(npm test {})" --continue-on-error

See examples below for detailed patterns.
```
Then EXIT without executing.

### 5. Report Results

After execution completes:
```
✅ /foreach Complete

Processed: N items
Successful: M items
Failed: K items
Duration: X minutes

[Summary of results]
```

## Examples

### Example 1: Iterate Over Glob Pattern

```bash
/foreach "src/**/*.ts" "analyze code structure and patterns in {}"
```

**What happens:**
- Finds all .ts files in src/ recursively
- For each file: Analyzes code structure
- Sequential execution (default)
- Stops on first error (default)

**Output:**
```
Processing 15 files...
✓ src/auth/login.ts - analyzed
✓ src/auth/logout.ts - analyzed
✓ src/api/users.ts - analyzed
...
✅ 15/15 files processed
```

**Use case:** Analyzing all source files of a type

### Example 2: Numeric Range Iteration

```bash
/foreach "1..10" "process batch number {}"
```

**What happens:**
- Generates sequence: 1, 2, 3, ..., 10
- For each number: Executes "process batch number N"
- Substitutes {} with current number

**Output:**
```
Processing 10 batches...
✓ Batch 1 complete
✓ Batch 2 complete
...
✅ 10/10 batches processed
```

**Use case:** Batch processing with numeric IDs

### Example 3: Parallel Execution

```bash
/foreach "*.mp4" "/yt {} -d" --parallel
```

**What happens:**
- Finds all .mp4 files in current directory
- Executes /yt command for each file **in parallel**
- Much faster for independent operations
- Collects results when all complete

**Output:**
```
Processing 5 videos in parallel...
✓ video1.mp4 complete (3.2 min)
✓ video3.mp4 complete (2.8 min)
✓ video2.mp4 complete (4.1 min)
✓ video5.mp4 complete (3.5 min)
✓ video4.mp4 complete (3.9 min)

✅ 5/5 videos processed
Total time: 4.1 min (vs ~17.5 min sequential)
```

**Use case:** Processing independent files that can run concurrently

### Example 4: Read Items from File

```bash
/foreach "@youtube-urls.txt" "/yt {} -a"
```

**File content (youtube-urls.txt):**
```
https://youtube.com/watch?v=abc123
https://youtube.com/watch?v=def456
https://youtube.com/watch?v=ghi789
```

**What happens:**
- Reads youtube-urls.txt (one URL per line)
- Processes each URL with /yt command
- Sequential to avoid rate limits

**Output:**
```
Processing 3 URLs from file...
✓ https://youtube.com/watch?v=abc123 - summarized
✓ https://youtube.com/watch?v=def456 - summarized
✓ https://youtube.com/watch?v=ghi789 - summarized

✅ 3/3 URLs processed
```

**Use case:** Batch processing from curated file list

### Example 5: Command Output as Source

```bash
/foreach "$(git diff --name-only)" "review changes in {}"
```

**What happens:**
- Executes `git diff --name-only` to get changed files
- Output might be: src/auth.ts, src/api.ts, tests/auth.test.ts
- Reviews each changed file with natural language instruction

**Output:**
```
Processing 3 changed files...
✓ src/auth.ts - reviewed
✓ src/api.ts - reviewed
✓ tests/auth.test.ts - reviewed

✅ 3/3 files reviewed
```

**Use case:** Processing dynamic command results

### Example 6: Continue on Errors

```bash
/foreach "tests/*.test.ts" "Bash(npm test {})" --continue-on-error
```

**What happens:**
- Finds all test files
- Runs each test file individually
- If one fails, continues to next (doesn't stop)
- Reports all failures at end

**Output:**
```
Processing 5 test files...
✓ tests/auth.test.ts passed
✗ tests/api.test.ts failed (3 tests failing)
✓ tests/utils.test.ts passed
✓ tests/db.test.ts passed
✗ tests/integration.test.ts failed (timeout)

✅ 3/5 passed, 2 failed

Failed tests:
  - tests/api.test.ts: 3 test failures
  - tests/integration.test.ts: timeout error
```

**Use case:** Running all tests regardless of failures

### Example 7: Integration with Agents

```bash
/foreach "modules/*/" "Task('analyze architecture and suggest improvements for {}', code-craftsman)"
```

**What happens:**
- Finds all module directories
- Invokes code-craftsman agent for each module
- Sequential analysis with full context
- Each agent invocation is independent

**Output:**
```
Processing 4 modules with code-craftsman...
✓ modules/auth/ - analysis complete
✓ modules/api/ - analysis complete
✓ modules/db/ - analysis complete
✓ modules/utils/ - analysis complete

✅ 4/4 modules analyzed
```

**Use case:** Agent-based batch processing with expertise

### Example 8: Custom Variable Name

```bash
/foreach "*.md" "check all links in {file} and report broken ones" --var=file
```

**What happens:**
- Uses `{file}` placeholder instead of default `{}`
- More readable in natural language commands
- Same substitution behavior

**Output:**
```
Processing 12 markdown files...
✓ README.md - 0 broken links
✓ CONTRIBUTING.md - 2 broken links found
✓ docs/api.md - 0 broken links
...
```

**Use case:** Clarity in complex natural language commands

### Example 9: List Iteration

```bash
/foreach "staging,production,development" "deploy to {env} environment" --var=env
```

**What happens:**
- Splits comma-separated list into items
- Processes each environment
- Uses custom variable name for clarity

**Output:**
```
Processing 3 environments...
✓ staging - deployment complete
✓ production - deployment complete
✓ development - deployment complete

✅ 3/3 environments deployed
```

**Use case:** Processing enumerated values

### Example 10: Parallel Agent Invocations

```bash
/foreach "features/*.feature" "Task('generate test cases for {}', test-engineer)" --parallel
```

**What happens:**
- Finds all feature files
- Invokes test-engineer agent for each **in parallel**
- Multiple agents run concurrently
- Collects all results when complete

**Output:**
```
Processing 6 features in parallel...
✓ features/auth.feature - 15 test cases generated (2.3 min)
✓ features/payment.feature - 22 test cases generated (3.1 min)
✓ features/search.feature - 18 test cases generated (2.8 min)
...

✅ 6/6 features processed
Total test cases: 98
Time: 3.2 min (vs ~15 min sequential)
```

**Use case:** Parallel independent agent work

## Error Handling

### Empty Source
```
⚠️ Pattern "*.xyz" matched 0 files

Suggestion: Check pattern or path
```

### Command Failure (Default Behavior)
```
Processing 10 files...
✓ file1.ts - success
✓ file2.ts - success
✗ file3.ts - error: Syntax error

❌ Stopped at file3.ts (3/10 processed)

Use --continue-on-error to process all files
```

### Command Failure (With --continue-on-error)
```
Processing 10 files...
✓ file1.ts - success
✓ file2.ts - success
✗ file3.ts - error logged
✓ file4.ts - success
...

⚠️ 7/10 successful, 3 failed

Failed items:
  - file3.ts: Syntax error
  - file6.ts: Timeout
  - file9.ts: Permission denied
```

### Invalid Syntax
```
❌ Invalid syntax

Expected: /foreach <source> "<command-template>"
Got: /foreach *.ts

Tip: Wrap command template in quotes if it contains spaces
```

## Source Type Detection

The command automatically detects source type:

| Pattern | Type | Example |
|---------|------|---------|
| `*`, `**`, `?` | Glob | `*.ts`, `src/**/*.js` |
| `N..M` | Range | `1..10`, `0..100` |
| `@filename` | File | `@urls.txt` |
| `$(cmd)` or `` `cmd` `` | Command | `$(git status -s)` |
| Commas | List | `a,b,c` or `item1, item2` |
| Default | List | Space-separated |

## Performance Considerations

### Sequential vs Parallel

**Use Sequential (default) when:**
- Order matters
- Operations modify shared state
- Rate limits apply
- Dependent operations

**Use --parallel when:**
- Independent operations
- IO-bound tasks (network, disk)
- No shared state
- Want maximum speed

**Performance comparison:**
```
10 independent 2-min tasks:
  Sequential: ~20 minutes
  Parallel:   ~2 minutes
```

## Integration Patterns

### With /yt Command
```bash
# Batch video summaries
/foreach "@video-list.txt" "/yt {} --detailed"

# Parallel processing
/foreach "*.mp4" "/yt {} -a" --parallel
```

### With Task() Agent Invocations
```bash
# Sequential analysis
/foreach "src/**/*.ts" "Task('review {} for security issues', debug-detective)"

# Parallel research
/foreach "topic1,topic2,topic3" "Task('research {}', deep-researcher)" --parallel
```

### With Bash Commands
```bash
# File operations
/foreach "*.log" "Bash(gzip {})"

# Test execution
/foreach "tests/*.js" "Bash(node {})" --continue-on-error
```

### With Other Slash Commands
```bash
# Deep research on multiple topics
/foreach "kubernetes,docker,nomad" "/deep -r 'production deployment with {}'"

# Context gathering
/foreach "lib1,lib2,lib3" "/ctx7 {}"
```

## Tips for Best Results

1. **Quote Command Templates**: Always wrap in quotes if contains spaces
   ```bash
   # Good
   /foreach "*.ts" "analyze {}"

   # Bad (breaks on spaces)
   /foreach *.ts analyze {}
   ```

2. **Use --parallel for Independent Tasks**: 5-10x speedup
   ```bash
   /foreach "*.mp4" "/yt {} -d" --parallel
   ```

3. **Custom Variables for Clarity**: Use `--var=name` for readable commands
   ```bash
   /foreach "staging,prod" "deploy to {env}" --var=env
   ```

4. **Continue on Errors for Batch Processing**: Get full report
   ```bash
   /foreach "tests/*.ts" "Bash(npm test {})" --continue-on-error
   ```

5. **File Lists for Curated Sets**: Use `@file.txt` for controlled iteration
   ```bash
   /foreach "@priority-files.txt" "review and fix {}"
   ```

## Limitations

- Maximum 1000 items per iteration (performance)
- Parallel execution limited to 10 concurrent operations
- Command output captured but may be truncated if very large
- Glob patterns follow standard glob syntax (no regex)

## Your Response

Execute the foreach loop and report:
```
✅ /foreach Complete

Processed: N items
Duration: X min

[Results summary with success/failure counts]
```

For errors, provide clear diagnostics and suggestions.
