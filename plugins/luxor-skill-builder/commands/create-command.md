---
description: Create slash command from /meta-agent specification
args:
  - name: spec_source
    description: Specification YAML (inline string or @file.yaml)
  - name: flags
    description: Optional --help, --dry-run, --examples-heavy, --overwrite
allowed-tools: Read(**/.claude/**), Write(**/.claude/commands/*.md), Glob(**/.claude/commands/*.md), Grep(**), TodoWrite
---

# Create Slash Command

Create command file from specification: $ARGUMENTS

## Existing Commands (reference patterns)
Use Glob tool to list commands if needed.

## Your Task

Parse the specification and create `.claude/commands/<name>.md` following proven patterns.

### 1. Parse Specification

Extract from $ARGUMENTS:
- Load YAML (inline or from @file path)
- Extract: command name, description, parameters, capabilities, examples
- Validate: required fields, no conflicts, proper structure

### 2. Generate Command File

Create `.claude/commands/<name>.md` with:

**Frontmatter:**
```yaml
---
description: One-line description (under 100 chars, from spec)
args:
  - name: param1
    description: Brief, clear description
  - name: param2
    description: Brief, clear description
allowed-tools: Tool(pattern:*), Tool2, ... (from spec permissions, optional)
---
```

**Body Structure:**
```markdown
# /command-name

Brief instruction about the task, referencing $ARGUMENTS

## Current Context (optional - use for dynamic commands)
Dynamic bash pattern: ![backtick]command[backtick] (executes shell command)

## Your Task

Clear, numbered steps describing what Claude should do:
1. First action (automatic)
2. Second action (automatic)
3. Validation or output

## Examples

[8-12 high-quality examples covering full scope - see below]

## Requirements (optional)
- Quality standards
- Validation rules
- Best practices

## Your Response
What to output when command completes
```

### 3. Generate Examples (CRITICAL)

**Create 8-12 comprehensive examples** covering the full scope:

**Sources for examples:**
1. **Spec examples** (copy directly, highest fidelity)
2. **Capabilities** (one example per major capability)
3. **Modes/options** (demonstrate each execution mode)
4. **Integration patterns** (with other commands)
5. **Edge cases** (error handling, boundary conditions)

**Example template:**
```markdown
### Example N: [Clear, Specific Description]

```bash
/command args --flags
```

**What happens:**
- Step-by-step explanation of behavior
- Expected outcomes
- Any side effects or state changes

**Output:** (if applicable)
```
Show realistic output
```

**Use case:** When to use this pattern
```

**Coverage checklist:**
- ✓ Basic usage (1-2 examples)
- ✓ Each major capability (1 example each)
- ✓ Common patterns (2-3 examples)
- ✓ Advanced/power features (1-2 examples)
- ✓ Integration with other commands (1-2 examples)
- ✓ Error handling (1 example)
- ✓ Edge cases (1 example if applicable)

### 4. Command Style Selection

Match style to command complexity:

**Simple command** (basic utility):
- Brief task description
- 5-8 focused examples
- Minimal sections
- Example: `/yt` style

**Standard command** (moderate complexity):
- Clear task sections
- 8-10 examples with variety
- Standard sections (Task, Examples, Requirements)
- Example: `/orch` style

**Complex command** (multiple modes/deep functionality):
- Comprehensive documentation
- 10-12 examples organized by category
- Multiple sections, mode descriptions
- Example: `/deep` style

**Meta command** (creates other commands):
- Very clear instructions
- 8-10 high-quality examples
- Include validation logic
- This command is meta!

### 5. Handle Flags

Parse from $ARGUMENTS:
- `--help`: Show usage guide and examples (don't create file)
- `--dry-run`: Show preview without creating file
- `--examples-heavy`: Generate 15+ examples (more coverage)
- `--overwrite`: Replace existing command file
- Default: 8-12 quality examples

**If `--help` flag detected:**
Show comprehensive help text:
```
📖 /create-command - Create Slash Command from Specification

USAGE:
  /create-command @spec-file.yaml [flags]
  /create-command "<yaml-string>" [flags]

ARGUMENTS:
  spec_source    Specification YAML (inline or @file path)

FLAGS:
  --help              Show this help message
  --dry-run           Preview without creating file
  --examples-heavy    Generate 15+ examples (default: 8-12)
  --overwrite         Replace existing command file

EXAMPLES:
  # Create from file
  /create-command @specs/foreach.spec.yaml

  # Create with more examples
  /create-command @specs/deep.spec.yaml --examples-heavy

  # Preview before creating
  /create-command "<yaml>" --dry-run

  # Replace existing command
  /create-command @specs/updated.spec.yaml --overwrite

WORKFLOW:
  1. Generate spec: /meta-agent "command description"
  2. Review specification output
  3. Create command: /create-command "<spec>"
  4. Test: /<command-name> args

See Examples section for detailed patterns.
```
Then EXIT without creating file.

### 6. Validation

Before writing:
- ✓ Valid YAML frontmatter
- ✓ Clear task description
- ✓ At least 6 examples (warn if fewer)
- ✓ Examples cover major capabilities
- ✓ Consistent command name throughout
- ✓ No conflicts (unless --overwrite)

### 7. Create File & Confirm

Write to: `.claude/commands/<name>.md`

Confirm with:
```
✅ Command created: .claude/commands/<name>.md

📊 Generated:
  - 10 comprehensive examples
  - N capability examples
  - N integration examples
  - Error handling

🎯 Test: /<name> --help
      /<name> test-args
```

## Examples

### Example 1: Basic Utility Command (Simple Style)

**Input:**
```bash
/create-command @specs/file-counter.spec.yaml
```

**Spec contains:**
```yaml
command:
  name: count-files
  description: Count files matching pattern
capabilities:
  - glob_matching
  - recursive_search
  - filtering
usage_examples:
  - "*.ts in src/"
  - "test files"
```

**Generated command:**
```markdown
---
description: Count files matching glob pattern
args:
  - name: pattern
    description: Glob pattern to match
---

# /count-files

Count files matching pattern: $ARGUMENTS

## Your Task

1. Parse glob pattern from arguments
2. Find all matching files
3. Count and categorize by extension
4. Display summary with totals

## Examples

### Example 1: Count TypeScript Files
\`\`\`bash
/count-files "src/**/*.ts"
\`\`\`
**What happens:** Finds all .ts files in src/, counts them

### Example 2: Count Test Files
\`\`\`bash
/count-files "**/*.test.ts"
\`\`\`
**What happens:** Finds all test files, shows distribution

[... 6 more quality examples covering filters, options, edge cases]
```

**Style:** Simple, focused, ~8 examples

### Example 2: Standard Command with Multiple Capabilities

**Input:**
```bash
/create-command "<foreach spec yaml>"
```

**Spec contains:**
```yaml
command:
  name: foreach
  description: Loop over items executing commands
capabilities:
  iteration_sources: [glob, list, range, file, command]
  execution_modes: [sequential, parallel, batched]
  variable_substitution: true
usage_examples: [8 examples in spec]
```

**Generated command:**
```markdown
---
description: Flexible loop construct for repeating commands
args:
  - name: source
    description: Iteration source (glob, list, range, file, command)
  - name: command_template
    description: Command to execute (use {} for substitution)
  - name: flags
    description: Optional --parallel, --continue-on-error
allowed-tools: Read(**), Bash(*), Glob(*), Task(*)
---

# /foreach

Execute command for each item in: $ARGUMENTS

## Your Task

1. Parse source and determine type (glob/list/range/file/command)
2. Expand source to item list
3. Parse command template and validate
4. Execute command for each item with substitution
5. Track progress and handle errors
6. Report results

## Examples

### Example 1: Iterate Over Glob Pattern
\`\`\`bash
/foreach "src/**/*.ts" "analyze code in {}"
\`\`\`

**What happens:**
- Finds all .ts files in src/
- Executes "analyze code in <file>" for each
- Sequential execution (default)

**Use case:** Processing all files of a type

### Example 2: Numeric Range
\`\`\`bash
/foreach "1..10" "process batch {}"
\`\`\`

**What happens:**
- Iterates numbers 1 through 10
- Substitutes {} with each number
- Executes "process batch 1", "process batch 2", etc.

**Use case:** Batch processing with numeric IDs

### Example 3: Parallel Execution
\`\`\`bash
/foreach "*.mp4" "/yt {} -d" --parallel
\`\`\`

**What happens:**
- Finds all .mp4 files
- Executes /yt command for each in parallel
- Faster for independent operations

**Output:**
\`\`\`
Processing 5 videos in parallel...
✓ video1.mp4 complete (3.2min)
✓ video2.mp4 complete (2.8min)
...
\`\`\`

**Use case:** When operations are independent

### Example 4: Read Items from File
\`\`\`bash
/foreach "@urls.txt" "/yt {} -a"
\`\`\`

**What happens:**
- Reads urls.txt (one URL per line)
- Processes each URL with /yt command
- Sequential to avoid rate limits

**Use case:** Batch processing from file list

### Example 5: Command Output as Source
\`\`\`bash
/foreach "$(git diff --name-only)" "review changes in {}"
\`\`\`

**What happens:**
- Executes git command to get changed files
- Iterates over each file
- Reviews changes with custom prompt

**Use case:** Processing command results

### Example 6: Continue on Errors
\`\`\`bash
/foreach "tests/*.ts" "Bash(npm test {})" --continue-on-error
\`\`\`

**What happens:**
- Runs each test file
- If one fails, continues to next
- Reports all failures at end

**Output:**
\`\`\`
✓ tests/auth.test.ts passed
✗ tests/api.test.ts failed
✓ tests/utils.test.ts passed

2/3 passed, 1 failed
\`\`\`

**Use case:** When you want to run all tests regardless

### Example 7: Integration with Agents
\`\`\`bash
/foreach "modules/*/" "Task('analyze architecture in {}', code-craftsman)"
\`\`\`

**What happens:**
- Finds all module directories
- Invokes code-craftsman agent for each
- Sequential analysis with full context

**Use case:** Agent-based batch processing

### Example 8: Custom Variable Name
\`\`\`bash
/foreach "*.md" "check links in {file}" --var=file
\`\`\`

**What happens:**
- Uses {file} instead of default {}
- More readable in natural language
- Same functionality

**Use case:** Clarity in complex commands

## Error Handling

**Empty source:**
```
⚠️ Pattern "*.xyz" matched 0 files
Suggestion: Check pattern or path
```

**Command fails:**
- Default: Stop on first error
- With --continue-on-error: Log and continue
```

**Style:** Standard, organized, 10 comprehensive examples covering all capabilities

### Example 3: Complex Multi-Mode Command

**Input:**
```bash
/create-command @specs/research.spec.yaml
```

**Spec contains:**
```yaml
command:
  name: deep
  description: Deep research with multiple modes
capabilities:
  modes: [research, thinking, web-fetch, web-search]
  parameters_per_mode: extensive
  integration: high
usage_examples: [15+ examples]
```

**Generated command structure:**
```markdown
---
description: Deep research with multi-source synthesis
args:
  - name: mode_and_query
    description: Mode flag (-r/-t/-wf/-ws) and topic/question
  - name: options
    description: Mode-specific options (--depth, --budget, etc)
allowed-tools: WebSearch, WebFetch, Task(*), TodoWrite
---

# /deep

Research or analyze: $ARGUMENTS

## Your Task

1. Parse mode flag: -r (research), -t (thinking), -wf (fetch), -ws (search)
2. Extract topic/question/url from arguments
3. Parse mode-specific options
4. Execute appropriate workflow for mode
5. Generate and format output
6. Save if --save flag present

## Modes

### Research Mode (-r, default)
Full research with WebSearch + WebFetch + synthesis

### Thinking Mode (-t)
Extended thinking for complex reasoning

### Web Fetch Mode (-wf)
Retrieve and analyze specific URLs

### Web Search Mode (-ws)
Quick search and summary

## Examples

### Example 1: Basic Research (Default Mode)
\`\`\`bash
/deep "microservices architecture patterns"
\`\`\`

**What happens:**
- Uses research mode (default)
- WebSearch finds sources
- WebFetch retrieves content
- Synthesizes comprehensive report

**Output:** 5-10 page research report
**Time:** ~15-20 minutes
**Use case:** Understanding a technical topic

### Example 2: Research with Industry Focus
\`\`\`bash
/deep -r "fintech industry trends 2025" --sources=industry --save=context/fintech.md
\`\`\`

**What happens:**
- Research mode with industry sources
- Focuses on market reports, business analysis
- Non-technical industry research
- Saves to context documentation

**Output:** Industry landscape report saved to file
**Use case:** Creating context for agents

### Example 3: Extended Thinking Mode
\`\`\`bash
/deep -t "optimal database sharding for 100M users" --budget=8192
\`\`\`

**What happens:**
- Thinking mode (no web research)
- 8192 token thinking budget
- Shows step-by-step reasoning
- Analyzes trade-offs deeply

**Output:** Transparent reasoning process + recommendation
**Use case:** Complex problem analysis

### Example 4: Web Fetch Specific URL
\`\`\`bash
/deep -wf https://docs.anthropic.com/api "extract key API capabilities"
\`\`\`

**What happens:**
- Directly fetches URL content
- Analyzes based on prompt
- No broad search
- Focused extraction

**Output:** API capabilities summary
**Use case:** Analyzing known documentation

### Example 5: Quick Web Search
\`\`\`bash
/deep -ws "latest AI developments" --recency=week --max-results=15
\`\`\`

**What happens:**
- Quick search mode
- Last week's content only
- Top 15 results
- Fast synthesis

**Output:** Quick summary with links
**Time:** ~2-3 minutes
**Use case:** Trend awareness

### Example 6: Comprehensive Research
\`\`\`bash
/deep -r "compare Kubernetes vs Nomad" --depth=comprehensive --save=docs/orchestration.md
\`\`\`

**What happens:**
- Deep dive with 20+ sources
- 30-45 minute research
- Comparison matrix
- Detailed analysis

**Output:** Comprehensive comparison document
**Use case:** Important architectural decisions

### Example 7: Multi-Stage Workflow
\`\`\`bash
# Stage 1: Quick discovery
/deep -ws "agent architecture patterns"

# Stage 2: Deep research
/deep -r "agent orchestration" --depth=comprehensive

# Stage 3: Specific analysis
/deep -wf https://paper-url.com "extract methodology"

# Stage 4: Complex reasoning
/deep -t "design optimal agent protocol" --budget=8192
\`\`\`

**What happens:** Complete research workflow combining all modes
**Use case:** Building comprehensive understanding

### Example 8: Research for Context Engineering
\`\`\`bash
/deep -r "healthcare AI regulations" --sources=industry --output=detailed --context="for agent context docs"
\`\`\`

**What happens:**
- Industry-focused research
- Detailed output format
- Considers context need
- Creates agent-ready documentation

**Output:** Context document for specialized agents
**Use case:** Preparing domain context for agents

## Mode Selection Guide

**Use -r (research)** when:
- Need comprehensive understanding
- Multiple sources required
- Building knowledge base

**Use -t (thinking)** when:
- Complex problem analysis
- Need reasoning transparency
- No web research needed

**Use -wf (web-fetch)** when:
- Have specific URL
- Analyzing documentation
- Known source deep dive

**Use -ws (web-search)** when:
- Quick overview needed
- Trend discovery
- Current events
```

**Style:** Complex, comprehensive, organized by mode, 10+ examples

### Example 4: Meta-Command (This Command!)

**Input:**
```bash
/create-command @specs/create-command.spec.yaml
```

**What you're creating now:**

**Key characteristics:**
- Meta-level (creates other commands)
- Clear validation logic
- Example generation strategy
- Quality-focused (8-12 examples, not 50)
- Style matching guidance

**Example structure:**
- Basic utility creation (simple)
- Standard command creation (moderate)
- Complex multi-mode creation (advanced)
- Meta-command creation (this!)
- Integration examples
- Error handling
- Dry-run preview
- Flag handling

### Example 5: Dry Run Preview

**Input:**
```bash
/create-command @specs/foreach.spec.yaml --dry-run
```

**What happens:**
- Parse specification completely
- Generate full command file content
- **DO NOT write to disk**
- Show preview with statistics

**Output:**
```
🔍 DRY RUN MODE - Preview Only

Command: /foreach
Output: .claude/commands/foreach.md
Status: ✓ Valid

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PREVIEW: First 80 lines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---
description: Flexible loop construct for repeating commands
args:
  - name: source
    description: Iteration source
...
[preview continues]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Statistics:
  Total lines: 342
  Examples: 10
  Sections: 7
  Capabilities covered: 5/5 ✓

✅ Validation: All checks passed

To create, run without --dry-run
```

**Use case:** Review before committing

### Example 6: Overwrite Existing Command

**Input:**
```bash
/create-command @specs/foreach-v2.spec.yaml --overwrite
```

**What happens:**
- Check if `.claude/commands/foreach.md` exists
- Create backup: `foreach.md.backup`
- Generate new version
- Show changes

**Output:**
```
⚠️ Overwriting existing command

Backup: .claude/commands/foreach.md.backup

Changes detected:
  + Added 3 new examples (parallel execution)
  + Updated error handling section
  + Added --var flag documentation
  ~ Modified 2 existing examples for clarity

✅ Command updated: .claude/commands/foreach.md

Test updated command: /foreach "*.ts" "echo {}"
```

**Use case:** Iterating on command design

### Example 7: Examples-Heavy Mode

**Input:**
```bash
/create-command @specs/complex.spec.yaml --examples-heavy
```

**What happens:**
- Generate 15+ examples instead of 8-12
- Include more edge cases
- Add anti-patterns section
- More integration examples

**Output:**
```
✅ Command created: .claude/commands/complex.md

📊 Generated (examples-heavy mode):
  - 18 comprehensive examples
  - 6 capability examples
  - 4 integration examples
  - 3 error scenarios
  - 2 edge cases
  - 2 anti-patterns
  - 1 performance optimization

Note: More examples = more comprehensive but longer file
```

**Use case:** Complex commands needing extensive coverage

### Example 8: Integration with /meta-agent

**Complete workflow:**
```bash
# Step 1: Generate specification
/meta-agent "command for security auditing with evidence reporting"

# Output: Detailed specification YAML

# Step 2: Review specification
# (Read the output, verify capabilities)

# Step 3: Create command
/create-command "<paste-specification-here>"

# Step 4: Test command
/security-audit src/ --severity=high
```

**What happens:**
- /meta-agent analyzes intent and patterns
- Generates specification with examples
- /create-command transforms spec to command file
- Command ready to use immediately

**Use case:** Complete command creation workflow

## Quality Standards

Every command you create must have:

✅ **Frontmatter:**
- Clear description under 100 chars
- Args documented if command is parameterized
- Allowed-tools specified if restricted

✅ **Task Section:**
- Clear instructions for Claude
- Numbered steps for complex commands
- References $ARGUMENTS appropriately

✅ **Examples (8-12):**
- Each example has clear description
- Shows actual command invocation
- Explains what happens
- Shows output when relevant
- Includes use case context

✅ **Coverage:**
- All major capabilities demonstrated
- Common patterns shown
- At least one integration example
- Error handling covered
- Edge cases if applicable

✅ **Consistency:**
- Command name consistent throughout
- Parameter names match
- Examples use realistic data
- Tone and format consistent

## Your Response

After creating the command file:

**If successful:**
```
✅ Command created: .claude/commands/<name>.md

📊 Generated:
  - N examples covering M capabilities
  - K integration patterns
  - Error handling

🎯 Test the command:
  /<name> test-args
  /<name> --help

💡 Next: Review generated file and test with real use cases
```

**If dry-run:**
```
🔍 DRY RUN - Preview shown above

To create: Remove --dry-run flag
```

**If errors:**
```
❌ Error: <specific issue>

Resolution: <how to fix>
```

Now create the command file from the specification!
