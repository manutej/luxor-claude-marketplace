---
description: Show current implementation status and roadmap position
---

## 🧪 Testing Current Functionality

**BEFORE analyzing project status, remind the user to test if needed:**

If any changes were made since last test run, review TESTING-GUIDE.md and run through:
- Pre-commit test checklist for affected areas
- Regression tests to ensure no breakage
- Document results in test results file

**Testing Guide:** See TESTING-GUIDE.md for comprehensive test scenarios

---

You are reviewing the unix-goto project implementation status. Provide a comprehensive overview of:

## Current Implementation Status

Analyze the codebase and documentation to show:

1. **Completed Features** (with version/phase completed)
   - List all implemented functionality
   - Reference specific files where implemented
   - Note any partial implementations

2. **In Progress**
   - Features partially implemented
   - Recent commits and changes
   - Current work focus based on git status

3. **Roadmap Position**
   - Current phase from ROADMAP.md
   - Next planned features
   - Progress percentage for current phase

4. **File Structure Status**
   - List all main files with their purpose
   - Identify any missing or planned files
   - Note any technical debt

5. **Recent Changes**
   - Summary of last 3-5 commits
   - Uncommitted changes
   - Staged vs unstaged work

6. **Next Steps**
   - Immediate next tasks based on roadmap
   - Suggested priorities
   - Any blockers or dependencies

## Format Requirements

- Use clear section headers with emojis
- Include file path references (file:line format)
- Show progress indicators (✅ Complete, 🔄 In Progress, ⏳ Planned)
- Be concise but comprehensive
- Highlight any issues or technical debt
- Reference specific version numbers or dates

## Actions

1. **ALWAYS read PROJECT-STATUS.md FIRST** - This is the canonical source of truth
2. Read ROADMAP.md to understand overall plan
3. Read CHANGELOG.md to see what's been completed
4. Check git status and recent commits
5. Scan lib/ directory for implemented features
6. Identify gaps between roadmap and implementation
7. Provide clear summary with actionable next steps

## IMPORTANT: Maintaining PROJECT-STATUS.md

**YOU MUST update PROJECT-STATUS.md after EVERY:**
- ✅ Milestone completion (even partial)
- ✅ Phase completion
- ✅ Version release (tag/commit)
- ✅ Significant feature implementation
- ✅ Major design decision
- ✅ Between commits if state changes

**Never lose track of project state!** This document is the single source of truth.
