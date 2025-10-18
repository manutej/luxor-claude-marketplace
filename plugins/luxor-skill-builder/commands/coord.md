---
description: Real-time interactive coordination session for complex multi-step work
allowed-tools: Task(*), Read(**), Write(**), TodoWrite, Bash(*)
---

# /coord

Start an interactive coordination session for complex multi-step work requiring human-in-the-loop guidance.

## Usage

```bash
# Start coordination session
/coord start "<overall-goal>"

# Check coordination status
/coord status

# Get next recommended action
/coord next

# Mark current step complete
/coord complete

# Skip current step
/coord skip "<reason>"

# End coordination session
/coord end
```

## Arguments

- `start "<goal>"`: Begin new coordination session with specified goal
- `status`: Show current coordination state and progress
- `next`: Get next recommended step
- `complete`: Mark current step as done and move to next
- `skip "<reason>"`: Skip current step with justification
- `end`: Finish coordination session and generate summary

## What It Does

The `/coord` command enables interactive, step-by-step coordination for complex work that benefits from human oversight at each stage.

### Start Coordination Session
1. Parses overall goal from arguments
2. Analyzes goal to identify major phases
3. Breaks down into sequential steps
4. Suggests optimal agent for each step
5. Creates coordination state in `.claude/coord/session.yaml`
6. Initializes TodoWrite tracking
7. Presents first step for approval

### Status Check
1. Reads current coordination session state
2. Shows completed steps with results
3. Displays current step in progress
4. Lists upcoming steps
5. Shows overall progress percentage
6. Estimates remaining time/tokens

### Next Step
1. Analyzes current progress
2. Determines next logical action
3. Considers dependencies and prerequisites
4. Suggests specific agent to use
5. Provides detailed step instructions
6. Updates coordination state

### Complete Step
1. Marks current step as complete
2. Captures outputs/artifacts created
3. Updates coordination session
4. Suggests next step
5. Updates TodoWrite progress
6. Adjusts remaining estimates

### Skip Step
1. Records skip reason for audit trail
2. Marks step as skipped (not complete)
3. Adjusts dependencies for subsequent steps
4. Suggests alternative if needed
5. Updates coordination state

### End Session
1. Marks all remaining steps as cancelled
2. Generates session summary report:
   - Completed steps with artifacts
   - Skipped steps with reasons
   - Total time and tokens consumed
   - Key outcomes achieved
3. Saves final state
4. Clears active coordination

## Examples

### Example 1: Start Coordination Session
```bash
/coord start "Build complete user authentication system with tests and documentation"
```

**Output**:
```
🎯 Coordination Session Started

Goal: Build complete user authentication system with tests and documentation

📋 Coordination Plan (6 steps):

1. ✅ Design authentication architecture
   Agent: api-architect
   Est: 16K tokens, ~12 min

2. ⏳ Implement auth endpoints
   Agent: code-craftsman
   Est: 18K tokens, ~14 min

3. ⏳ Create database schema
   Agent: api-architect
   Est: 14K tokens, ~10 min

4. ⏳ Implement auth middleware
   Agent: code-craftsman
   Est: 16K tokens, ~12 min

5. ⏳ Create comprehensive tests
   Agent: test-engineer
   Est: 14K tokens, ~11 min

6. ⏳ Generate documentation
   Agent: docs-generator
   Est: 12K tokens, ~9 min

Total estimate: 90K tokens, ~68 minutes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶️  Step 1: Design authentication architecture

I'll use api-architect to design the authentication system architecture.
This includes:
  • API endpoint structure
  • Authentication flow (JWT, sessions, OAuth)
  • Security considerations
  • Database requirements

Proceed with this step? [Y/n]
```

### Example 2: Check Status During Session
```bash
/coord status
```

**Output**:
```
📊 Coordination Session Status

Goal: Build complete user authentication system

Progress: 2 of 6 steps complete (33%)

✅ Completed Steps:
  1. Design authentication architecture
     Agent: api-architect
     Completed: 15 min ago
     Outputs:
       • docs/auth-architecture.md
       • api/auth-endpoints.yaml
     Tokens: 15,234 (vs 16,000 est)

  2. Implement auth endpoints
     Agent: code-craftsman
     Completed: 2 min ago
     Outputs:
       • src/auth/routes.ts
       • src/auth/controllers.ts
     Tokens: 17,890 (vs 18,000 est)

🔄 Current Step:
  3. Create database schema
     Agent: api-architect
     Status: In progress
     Started: Just now
     Est remaining: 10 min

⏳ Upcoming Steps:
  4. Implement auth middleware (16K tokens, ~12 min)
  5. Create comprehensive tests (14K tokens, ~11 min)
  6. Generate documentation (12K tokens, ~9 min)

📊 Estimates:
  Completed: 33,124 tokens, 15 min
  Remaining: ~56,000 tokens, ~42 min
  On track: ✅ (within estimates)

💾 Session: .claude/coord/session.yaml

Commands:
  /coord next     - Get next recommendation
  /coord complete - Mark current step done
  /coord skip     - Skip current step
  /coord end      - Finish session
```

### Example 3: Get Next Recommendation
```bash
/coord next
```

**Output**:
```
🎯 Next Step Recommendation

Current: Step 3 complete ✅
Next: Step 4 - Implement auth middleware

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 4: Implement auth middleware

Suggested Agent: code-craftsman

Description:
  Create authentication middleware that:
    • Validates JWT tokens
    • Checks user permissions
    • Handles token refresh
    • Provides role-based access control

Dependencies Met:
  ✅ Auth architecture designed (Step 1)
  ✅ Database schema created (Step 3)

Prerequisites:
  • Read outputs from Step 1 (architecture docs)
  • Read outputs from Step 3 (schema)
  • Access to src/auth/ directory

Recommended Invocation:
  Task(
    prompt="Implement authentication middleware based on architecture design. Include JWT validation, permission checking, and RBAC. Use database schema from Step 3.",
    subagent_type="code-craftsman"
  )

Estimated: 16K tokens, ~12 min

▶️  Proceed with Step 4? [Y/n/skip]
```

### Example 4: Complete Current Step
```bash
/coord complete
```

**Output**:
```
✅ Step 4 Complete: Implement auth middleware

Captured Outputs:
  • src/auth/middleware.ts
  • src/auth/rbac.ts
  • src/auth/jwt-validator.ts

Actual vs Estimated:
  Tokens: 15,678 vs 16,000 (2% under estimate) ✅
  Time: 11 min vs 12 min (on schedule) ✅

Updated Progress: 4 of 6 steps (67%)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Next Up: Step 5 - Create comprehensive tests

This step will:
  • Create unit tests for auth endpoints
  • Add integration tests for full auth flow
  • Test middleware and RBAC
  • Verify security requirements

Suggested Agent: test-engineer
Estimated: 14K tokens, ~11 min

Ready to proceed? [Y/n]

Commands:
  /coord next     - See detailed step info
  /coord status   - Review overall progress
  /coord skip     - Skip this step
  /coord end      - Finish coordination
```

### Example 5: Skip a Step
```bash
/coord skip "Tests will be added in separate PR per team policy"
```

**Output**:
```
⏭️  Step 5 Skipped: Create comprehensive tests

Reason: Tests will be added in separate PR per team policy

⚠️  Impact Assessment:
  • Documentation generation can still proceed
  • No blocking dependencies for remaining steps
  • Recommend tracking in separate task

Updated Progress: 4 of 6 steps complete, 1 skipped (83%)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Next Up: Step 6 - Generate documentation (final step)

This step will:
  • Document authentication API
  • Create usage examples
  • Document middleware usage
  • Security best practices guide

Suggested Agent: docs-generator
Estimated: 12K tokens, ~9 min

Ready to proceed with final step? [Y/n]
```

### Example 6: End Coordination Session
```bash
/coord end
```

**Output**:
```
🎉 Coordination Session Complete

Goal: Build complete user authentication system

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Duration: 58 minutes
Total tokens: 73,892 (vs 90K estimated - 18% savings!)

✅ Completed Steps (5):

1. Design authentication architecture
   Agent: api-architect | 15,234 tokens | 15 min
   Outputs:
     • docs/auth-architecture.md
     • api/auth-endpoints.yaml

2. Implement auth endpoints
   Agent: code-craftsman | 17,890 tokens | 14 min
   Outputs:
     • src/auth/routes.ts
     • src/auth/controllers.ts

3. Create database schema
   Agent: api-architect | 13,456 tokens | 9 min
   Outputs:
     • db/schema/auth.sql
     • db/migrations/001_auth.sql

4. Implement auth middleware
   Agent: code-craftsman | 15,678 tokens | 11 min
   Outputs:
     • src/auth/middleware.ts
     • src/auth/rbac.ts
     • src/auth/jwt-validator.ts

6. Generate documentation
   Agent: docs-generator | 11,634 tokens | 9 min
   Outputs:
     • docs/api/authentication.md
     • docs/guides/auth-setup.md
     • examples/auth-usage.ts

⏭️  Skipped Steps (1):

5. Create comprehensive tests
   Reason: Tests will be added in separate PR per team policy
   Recommendation: Track in separate coordination or workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Key Outcomes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Complete authentication system implemented
✅ API endpoints with JWT support
✅ Database schema and migrations
✅ Middleware with RBAC
✅ Comprehensive documentation
⚠️  Tests pending (tracked separately)

📁 Artifacts Created (12 files):
  • 3 documentation files
  • 5 source code files
  • 2 database files
  • 2 configuration files

📊 Efficiency Metrics:
  • Token efficiency: 118% (used less than estimated)
  • Time efficiency: 98% (on schedule)
  • Completion rate: 83% (5 of 6 steps)

🎯 Recommended Next Steps:
  1. Create separate PR for tests
  2. Review security implementation
  3. Deploy to staging environment

💾 Session saved: .claude/coord/session-2025-10-12-auth.yaml

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Tip: Save this coordination as a workflow?
   /wflw --from-session session-2025-10-12-auth
```

## Coordination Session File Format

Sessions are saved in `.claude/coord/session.yaml`:

```yaml
# session-2025-10-12-auth.yaml
session_id: session-2025-10-12-auth
goal: Build complete user authentication system with tests and documentation
started: 2025-10-12T14:30:00Z
ended: 2025-10-12T15:28:00Z
status: completed

steps:
  - id: 1
    description: Design authentication architecture
    agent: api-architect
    status: completed
    started: 2025-10-12T14:30:00Z
    completed: 2025-10-12T14:45:00Z
    estimated_tokens: 16000
    actual_tokens: 15234
    outputs:
      - docs/auth-architecture.md
      - api/auth-endpoints.yaml

  - id: 2
    description: Implement auth endpoints
    agent: code-craftsman
    status: completed
    started: 2025-10-12T14:46:00Z
    completed: 2025-10-12T15:00:00Z
    estimated_tokens: 18000
    actual_tokens: 17890
    outputs:
      - src/auth/routes.ts
      - src/auth/controllers.ts

  # ... more steps

  - id: 5
    description: Create comprehensive tests
    agent: test-engineer
    status: skipped
    skip_reason: "Tests will be added in separate PR per team policy"
    estimated_tokens: 14000

summary:
  total_steps: 6
  completed: 5
  skipped: 1
  cancelled: 0
  duration_minutes: 58
  total_tokens: 73892
  estimated_tokens: 90000
  efficiency: 118%
```

## Use Cases

### 1. Complex Multi-Phase Projects
When work involves multiple agents across phases and you want human approval between steps.

### 2. Exploratory Development
When the path isn't fully clear upfront and decisions need to be made based on intermediate results.

### 3. Learning & Training
When learning how agents work together and want to understand each step in detail.

### 4. High-Stakes Work
When mistakes are costly and you want verification at each stage.

### 5. Dependency Management
When steps have complex dependencies and you need to ensure prerequisites are met.

## Integration Points

### With /orch
- Coordination sessions can be converted to workflows
- `/orch` can use coordination session results
- Complementary approaches: coord for interactive, orch for automated

### With /wflw
- Successful coordination sessions can be saved as workflows
- `/wflw --from-session <session-id>` creates reusable workflow
- Learn from coordination to optimize workflows

### With TodoWrite
- Automatically tracks coordination progress
- Updates todos as steps complete
- Maintains audit trail

### With /context-budget
- Monitors token usage during coordination
- Warns if approaching limits
- Tracks actual vs estimated costs

## Tips for Best Results

1. **Clear Goals**: Provide specific, actionable goals when starting
2. **Review Estimates**: Check token/time estimates before proceeding
3. **Capture Outputs**: Note important artifacts at each step
4. **Skip Appropriately**: Skip with clear reasons for audit trail
5. **Save Sessions**: Convert successful sessions to workflows
6. **Use Status Often**: Check progress regularly during long sessions
7. **End Properly**: Always use `/coord end` for complete summary

## Related Commands

- `/orch` - Automated agent orchestration (non-interactive)
- `/wflw --from-session` - Convert coordination to workflow
- `/context-budget` - Monitor token usage
- `/crew` - Discover agents for coordination steps

## Version History

- v1.0: Initial interactive coordination
- v1.1: Session persistence
- v1.2: Convert to workflow feature
- v1.3: Enhanced status tracking

## Philosophy

Sometimes automation isn't the answer—you need human judgment at critical decision points. The `/coord` command provides structured, step-by-step coordination where you approve each stage while maintaining momentum and context. Think of it as pair programming with AI agents, where you're the senior engineer guiding the work.

Perfect for exploration, learning, or high-stakes work where oversight matters more than speed.
