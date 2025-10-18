# unix-goto Development Skill

Expert guidance for developing features in the unix-goto shell navigation tool.

## Overview

This skill provides comprehensive expertise for unix-goto development, including:

- **Architecture Knowledge**: Cache system (O(1) lookup), bookmarks, history tracking, module dependencies
- **9-Step Feature Workflow**: Standard process for adding any new feature
- **Testing Requirements**: 100% test coverage for all core features
- **Performance Standards**: <100ms cached navigation, >90% cache hit rate
- **Linear Integration**: Complete workflow for issue tracking and project management
- **API Documentation**: Patterns for documenting shell modules
- **Best Practices**: Code style, commit standards, debugging tips

## When to Use

Use this skill when:
- Developing new features for unix-goto
- Implementing cache-based navigation optimizations
- Adding bookmarks, history, or navigation commands
- Following the standard development workflow
- Writing comprehensive test suites
- Optimizing performance to meet targets
- Creating API documentation
- Integrating with Linear project management

## Key Features

### Architecture Patterns
- Cache system: O(1) lookup with auto-refresh
- Bookmarks: Fast access to frequent locations
- History tracking: Stack-based navigation
- Module dependencies: Critical load order

### 9-Step Development Workflow
1. Plan your feature
2. Create module (if needed)
3. Add to loader
4. Integrate with main function
5. Add tests (100% coverage)
6. Document API
7. Update user documentation
8. Performance validation
9. Linear issue update & commit

### Performance Targets
- Cached navigation: <100ms (achieved: 26ms)
- Cache build: <5s (achieved: 3-5s)
- Cache hit rate: >90% (achieved: 92-95%)
- Speedup ratio: >20x (in progress: 8x)
- Test coverage: 100%

## Installation

This skill is already installed at:
```
~/Library/Application Support/Claude/skills/unix-goto-development/
```

## Usage

Simply mention unix-goto development tasks in your conversation with Claude:

```
"I need to add a recent directories feature to unix-goto"
"Help me implement bookmark navigation with 100% test coverage"
"Create a cache optimization following the 9-step workflow"
```

Claude will automatically activate this skill and guide you through the complete development process.

## Examples

### Example 1: Adding a New Feature
```
"I need to add a 'goto recent' command to show recently visited directories.
Follow the 9-step workflow and ensure 100% test coverage."
```

Claude will:
1. Help you plan the feature (interface, performance, dependencies)
2. Generate the module code
3. Show you how to add it to the loader
4. Integrate with the main goto function
5. Create comprehensive tests (unit, integration, edge cases, performance)
6. Generate API documentation
7. Update README
8. Validate performance
9. Create proper commit message

### Example 2: Optimizing Performance
```
"The cache lookup is taking 150ms. Help me optimize it to meet the <100ms target."
```

Claude will:
- Analyze the current implementation
- Identify performance bottlenecks
- Suggest optimizations
- Help implement changes
- Create performance tests
- Validate against targets

## Skill Contents

- **SKILL.md** (1,269 lines): Complete development expertise
  - Architecture patterns
  - 9-step workflow
  - Testing requirements
  - Performance standards
  - Linear integration
  - Code examples
  - Best practices

## Version

- **Version**: 1.0
- **Created**: October 2025
- **Source**: unix-goto project knowledge base
- **Lines**: 1,269

## Related Skills

- **shell-testing-framework**: Testing expertise for bash scripts
- **performance-benchmark-specialist**: Performance benchmarking patterns
- **linear-dev-accelerator**: Linear project management integration

## License

This skill is created for the unix-goto project by Manu Tej + Claude Code.
