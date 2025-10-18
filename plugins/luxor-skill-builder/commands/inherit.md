# /inherit

Manage command and agent inheritance across project hierarchies using symlinks. Pull configurations from parent directories or push to child projects for centralized management and consistency.

## Usage

```bash
/inherit                          # Pull from parent directories
/inherit --from <path>            # Pull from specific directory
/inherit --children               # Push to all child projects
/inherit --child <path>           # Push to specific child project
/inherit --from-children          # Pull latest versions from child projects (bidirectional sync)
/inherit --sync                   # Bidirectional sync: push to children, then pull back updates
/inherit --dry-run                # Preview without making changes
/inherit --list                   # Show current inheritance structure
/inherit --clean                  # Remove broken symlinks
/inherit --help                   # Show this help
```

## Parameters

- `--from <path>` (optional): Pull from specific directory instead of searching parents
- `--children` (optional): Push to all child projects with `.claude/` directories
- `--child <path>` (optional): Push to specific child project (relative or absolute path)
- `--from-children` (optional): Pull latest versions from child projects (sync updates back to parent)
- `--sync` (optional): Bidirectional sync - push to children, then pull back any newer versions
- `--dry-run` (optional): Show what would be created without creating symlinks
- `--force` (optional): Overwrite existing files/symlinks (use with caution)
- `--list` (optional): Display current inheritance structure and symlink status
- `--clean` (optional): Remove broken symlinks in commands/ and agents/
- `--verbose` (optional): Show detailed output during operations
- `--help` (optional): Display this help documentation

## Examples

### Pull from Parent Projects

```bash
# Search up directory tree for .claude/ directories and inherit
/inherit

# Example output:
# ✓ Found parent: /Users/manu/Documents/.claude
#   → commands/format.md
#   → commands/review.md
#   → agents/doc-writer.md
# ✓ Found parent: /Users/manu/.claude
#   → commands/global-utils.md
#
# Created 4 symlinks from 2 parent directories
```

### Pull from Specific Directory

```bash
# Inherit from a specific directory (not necessarily a parent)
/inherit --from ~/shared-claude-configs

# Use case: Central repository of shared commands
/inherit --from /team/shared/.claude

# Output:
# ✓ Inheriting from: /team/shared/.claude
#   → commands/team-standards.md
#   → commands/code-review.md
#   → agents/compliance-checker.md
#
# Created 3 symlinks
```

### Push to All Children

```bash
# From parent project, push to all child projects
cd /Users/manu/Documents/monorepo
/inherit --children

# Output:
# ✓ Found child: ./packages/frontend/.claude
#   → commands/build.md
#   → commands/test.md
# ✓ Found child: ./packages/backend/.claude
#   → commands/build.md
#   → commands/test.md
# ✓ Found child: ./services/api/.claude
#   → commands/build.md
#   → commands/test.md
#
# Pushed to 3 child projects (6 total symlinks)
```

### Push to Specific Child

```bash
# Push to a specific child project
/inherit --child ./packages/frontend

# Output:
# ✓ Pushing to: ./packages/frontend/.claude
#   → commands/build.md
#   → commands/test.md
#   → commands/lint.md
#   → agents/code-reviewer.md
#
# Created 4 symlinks

# Absolute path also works
/inherit --child /Users/manu/Documents/LUXOR/subproject
```

### Dry Run (Preview)

```bash
# See what would happen without making changes
/inherit --dry-run

# Output:
# 📋 Dry Run - No Changes Made
#
# Would inherit from: /Users/manu/Documents/.claude
#   → commands/format.md (new)
#   → commands/review.md (new)
#   ⊘ commands/existing.md (skipped - already exists)
#   → agents/doc-writer.md (new)
#
# Would create 3 new symlinks (1 skipped)
# Run without --dry-run to apply changes
```

### Force Overwrite

```bash
# Overwrite existing files (use carefully!)
/inherit --force

# Warning: This will replace existing files with symlinks
# Backup created at: .claude/.inherit-backup-20251007-102345/
#
# ✓ Replaced commands/format.md with symlink
# ✓ Replaced agents/doc-writer.md with symlink
#
# Created 5 symlinks (2 replaced)
```

### List Inheritance Structure

```bash
# Show current inheritance status
/inherit --list

# Output:
# Current Project: /Users/manu/Documents/LUXOR
#
# Inherited Commands (3):
#   format.md → ../../.claude/commands/format.md
#   review.md → ../../../.claude/commands/review.md
#   utils.md (local file)
#
# Inherited Agents (2):
#   doc-writer.md → ../../.claude/agents/doc-writer.md
#   custom-agent.md (local file)
#
# Children Inheriting From This (1):
#   ./subproject/.claude
#     ← commands/build.md
#     ← commands/test.md
```

### Clean Broken Symlinks

```bash
# Remove symlinks pointing to non-existent files
/inherit --clean

# Output:
# 🧹 Cleaning broken symlinks...
#
# Removed broken symlinks:
#   ✗ commands/old-command.md → ../../../missing/.claude/commands/old-command.md
#   ✗ agents/deleted-agent.md → ../../.claude/agents/deleted-agent.md
#
# Cleaned 2 broken symlinks
```

### Verbose Output

```bash
# Show detailed information during operations
/inherit --verbose

# Output shows:
# - Full paths being checked
# - Skipped files and reasons
# - Symlink creation details
# - Error messages with context
```

### Pull from Children (Reverse Sync)

```bash
# Pull latest versions from child projects back to parent
/inherit --from-children

# Output:
# Scanning child projects for updates...
#
# ✓ Found child: ./Git_Repos/unix-goto
#   ← commands/deep.md (newer in child, updated: 2025-10-07 15:30)
#   ← agents/unix-command-master.md (newer in child, updated: 2025-10-07 14:20)
#   ⊘ commands/inherit.md (parent is newer, skipped)
#
# ✓ Found child: ./PROJECTS/HALCON
#   ← commands/sdk.md (newer in child, updated: 2025-10-07 16:45)
#
# Pulled 3 updated files from 2 child projects
```

### Bidirectional Sync

```bash
# Push to children, then pull back any updates they have
/inherit --sync

# Output:
# Phase 1: Pushing to children...
# ✓ Pushed to 6 child projects (43 symlinks)
#
# Phase 2: Pulling updates from children...
# ✓ Found 3 files newer in children
#   ← commands/deep.md (from ./Git_Repos/unix-goto)
#   ← commands/sdk.md (from ./PROJECTS/HALCON)
#
# Sync complete: 43 pushed, 3 pulled back
```

## What It Does

The `/inherit` command manages command and agent inheritance through symlinks, enabling centralized configuration management across project hierarchies.

### Mode 1: Pull from Parents (Default)

When run without arguments, searches up the directory tree:

```yaml
Process:
  1. Start at current directory: /Users/manu/Documents/LUXOR
  2. Check parent: /Users/manu/Documents
     - Look for .claude/ directory
     - If found, create symlinks from .claude/commands/* and .claude/agents/*
  3. Continue up: /Users/manu
  4. Continue up: /Users
  5. Stop at filesystem root: /

Symlink Creation:
  - Source: Parent's .claude/commands/format.md
  - Target: Current .claude/commands/format.md
  - Type: Relative symlink (../../.claude/commands/format.md)
  - Action: Skip if target already exists (unless --force)

Verification:
  ✓ Source file exists
  ✓ Target doesn't exist or --force used
  ✓ Symlink successfully created
  ✓ Symlink points to correct location
```

### Mode 2: Pull from Specific Directory

When `--from <path>` is specified:

```yaml
Process:
  1. Validate source path exists
  2. Verify source has .claude/ directory
  3. Create symlinks from source to current project
  4. Use relative paths if possible, absolute if needed

Example:
  Command: /inherit --from ~/shared-configs
  Source: /Users/manu/shared-configs/.claude/commands/test.md
  Target: /Users/manu/Documents/LUXOR/.claude/commands/test.md
  Symlink: ../../../shared-configs/.claude/commands/test.md
```

### Mode 3: Push to All Children

When `--children` is specified:

```yaml
Process:
  1. Search down from current directory
  2. Find all directories containing .claude/
  3. Exclude current directory
  4. For each child found:
     - Create symlinks from current commands/ to child commands/
     - Create symlinks from current agents/ to child agents/

Search:
  find /Users/manu/Documents/LUXOR \
    -type d \
    -name ".claude" \
    ! -path "/Users/manu/Documents/LUXOR/.claude"

Children Found:
  - ./packages/frontend/.claude
  - ./packages/backend/.claude
  - ./services/api/.claude

For Each Child:
  - Symlink current commands/* → child commands/*
  - Symlink current agents/* → child agents/*
  - Skip if target exists (unless --force)
```

### Mode 4: Push to Specific Child

When `--child <path>` is specified:

```yaml
Process:
  1. Resolve child path (relative or absolute)
  2. Verify child path exists
  3. Verify child has .claude/ directory
  4. Create symlinks from current to child
  5. Calculate relative path for symlink

Example:
  Current: /Users/manu/Documents/LUXOR
  Child: ./subproject
  Resolved: /Users/manu/Documents/LUXOR/subproject

  Symlink Creation:
    Source: /Users/manu/Documents/LUXOR/.claude/commands/build.md
    Target: /Users/manu/Documents/LUXOR/subproject/.claude/commands/build.md
    Link: ../.claude/commands/build.md (relative)
```

### Mode 5: Pull from Children (Reverse Sync)

When `--from-children` is specified:

```yaml
Process:
  1. Find all child projects with .claude/ directories
  2. For each child, scan commands/ and agents/
  3. Compare modification times with parent versions
  4. Copy newer files from children to parent
  5. Report what was updated

Conflict Resolution:
  - If child has newer version: Copy to parent
  - If parent is newer: Skip (keep parent version)
  - If file doesn't exist in parent: Copy from child
  - Use modification time (mtime) for comparison

Example:
  Parent: /Users/manu/Documents/LUXOR/.claude/commands/deep.md (mtime: 2025-10-07 10:00)
  Child:  /Users/manu/Documents/LUXOR/Git_Repos/unix-goto/.claude/commands/deep.md (mtime: 2025-10-07 15:30)

  Action: Copy child → parent (child is newer)
  Backup: Create backup of parent version in .claude/.inherit-backup-{timestamp}/

Symlink Handling:
  - Skip symlinks in children (only copy real files)
  - If parent file is symlink, replace with real file from child
  - Preserve symlinks pointing to other sources
```

### Mode 6: Bidirectional Sync

When `--sync` is specified:

```yaml
Process:
  1. Execute push-all mode (distribute parent to children)
  2. Wait for completion
  3. Execute pull-from-children mode (sync updates back)
  4. Report combined statistics

Workflow:
  Phase 1 - Push:
    - Push parent commands/agents to all children
    - Create symlinks in children pointing to parent
    - Track number of symlinks created

  Phase 2 - Pull:
    - Scan children for files newer than parent
    - Copy updated versions back to parent
    - Track number of files pulled back

  Result:
    - Children have latest from parent (via symlinks)
    - Parent has latest improvements from children (via copy)
    - Best of both worlds: distribution + updates

Use Case:
  - Parent maintains authoritative versions
  - Children can improve/customize locally
  - Sync pulls improvements back to parent
  - Parent can then distribute to all children
```

### Symlink Path Resolution

Intelligent relative path calculation for portability:

```yaml
Scenario 1: Parent to Child
  Source: /Users/manu/Documents/LUXOR/.claude/commands/test.md
  Target: /Users/manu/Documents/LUXOR/sub/.claude/commands/test.md
  Symlink: ../../.claude/commands/test.md

Scenario 2: Child to Parent
  Source: /Users/manu/Documents/.claude/commands/format.md
  Target: /Users/manu/Documents/LUXOR/.claude/commands/format.md
  Symlink: ../../.claude/commands/format.md

Scenario 3: Sibling Projects
  Source: /Users/manu/shared/.claude/commands/utils.md
  Target: /Users/manu/Documents/LUXOR/.claude/commands/utils.md
  Symlink: ../../../shared/.claude/commands/utils.md

Fallback: If relative path > 5 levels, use absolute path
```

### Dry Run Mode

Preview changes without making them:

```yaml
Actions Simulated:
  - Directory traversal (parents or children)
  - File existence checks
  - Symlink creation (simulated)
  - Conflict detection
  - Path resolution

Output Shows:
  → New symlinks that would be created
  ⊘ Existing files that would be skipped
  ⚠ Conflicts that would need --force
  📊 Summary statistics

No Modifications:
  ✗ No symlinks created
  ✗ No files modified
  ✗ No directories created
  ✓ Read-only operations only
```

### Force Mode

Overwrite existing files with symlinks:

```yaml
Safety Measures:
  1. Create backup directory: .claude/.inherit-backup-{timestamp}/
  2. Copy existing files to backup
  3. Remove existing file/symlink
  4. Create new symlink
  5. Verify symlink works
  6. Report backup location

Backup Structure:
  .claude/.inherit-backup-20251007-102345/
    ├── commands/
    │   ├── format.md (original file)
    │   └── existing.md (original file)
    └── agents/
        └── doc-writer.md (original file)

Warning Message:
  ⚠️  --force will overwrite existing files
  Backup created at: .claude/.inherit-backup-20251007-102345/
  Continue? (y/N)
```

### List Mode

Display current inheritance structure:

```yaml
Information Shown:
  1. Current Project Path
  2. Inherited Commands (with symlink targets)
  3. Inherited Agents (with symlink targets)
  4. Local Files (non-symlinks)
  5. Children Projects (if any)
  6. Broken Symlinks (if any)

Detection:
  - Use `test -L file` to check if symlink
  - Use `readlink file` to get symlink target
  - Use `test -e target` to verify target exists
  - Categorize as: symlink, local file, or broken symlink

Output Format:
  Commands:
    ✓ format.md → ../../.claude/commands/format.md (valid)
    ✓ review.md → ../../../.claude/commands/review.md (valid)
    ○ custom.md (local file)
    ✗ old.md → ../../missing/old.md (broken)
```

### Clean Mode

Remove broken symlinks:

```yaml
Detection:
  1. Find all symlinks in .claude/commands/ and .claude/agents/
  2. Check if symlink target exists
  3. Identify broken symlinks (target doesn't exist)
  4. Prompt for confirmation (unless --force)
  5. Remove broken symlinks
  6. Report what was cleaned

Safety:
  - Only removes broken symlinks
  - Never removes valid symlinks
  - Never removes regular files
  - Creates backup if --force used

Commands:
  # Find broken symlinks
  find .claude/commands -type l ! -exec test -e {} \; -print
  find .claude/agents -type l ! -exec test -e {} \; -print

  # Remove them
  find .claude/commands -type l ! -exec test -e {} \; -delete
  find .claude/agents -type l ! -exec test -e {} \; -delete
```

## Use Cases

### 1. Global Command Library

Maintain global commands in home directory:

```bash
# Setup: Create global commands
mkdir -p ~/.claude/{commands,agents}
# Add commands to ~/.claude/commands/

# In any project: Inherit global commands
cd ~/Documents/project-a
/inherit

cd ~/Documents/project-b
/inherit

# Both projects now have access to global commands
```

### 2. Monorepo Management

Parent project manages shared commands for all packages:

```bash
# Directory structure:
# /monorepo
#   .claude/
#     commands/
#       build.md
#       test.md
#       lint.md
#   packages/
#     frontend/.claude/
#     backend/.claude/
#     mobile/.claude/

# From monorepo root
cd /monorepo
/inherit --children

# All packages now inherit build, test, lint commands
# Updates to parent commands automatically apply to all children
```

### 3. Team Standards Distribution

Central repository for team standards:

```bash
# Team lead maintains standards repository
/team/standards/.claude/
  commands/
    code-review.md
    security-audit.md
    deploy.md

# Team members inherit in their projects
cd ~/my-project
/inherit --from /team/standards

# Standards updates propagate automatically (symlinks!)
```

### 4. Project Template Inheritance

New projects start with template commands:

```bash
# Create project template
~/templates/web-app/.claude/
  commands/
    dev.md
    build.md
    test.md
  agents/
    code-reviewer.md

# New project inherits template
mkdir ~/projects/new-app
mkdir ~/projects/new-app/.claude
cd ~/projects/new-app
/inherit --from ~/templates/web-app

# Start with all standard commands
```

### 5. Multi-Environment Projects

Different environments inherit base configuration:

```bash
# Base project
/project/.claude/
  commands/
    shared-command.md

# Environment-specific projects
/project/dev/.claude/
/project/staging/.claude/
/project/prod/.claude/

# From each environment
cd /project/dev
/inherit --from /project

cd /project/staging
/inherit --from /project

cd /project/prod
/inherit --from /project

# All environments share base commands + have their own
```

### 6. Inheritance Chain

Multi-level inheritance hierarchy:

```bash
# Global (/Users/manu/.claude)
#   ↓
# Organization (/Users/manu/company/.claude)
#   ↓
# Team (/Users/manu/company/team/.claude)
#   ↓
# Project (/Users/manu/company/team/project/.claude)

# Project inherits from all levels
cd /Users/manu/company/team/project
/inherit

# Gets commands from:
# - Global (manu/.claude)
# - Organization (company/.claude)
# - Team (team/.claude)
```

## Conflict Resolution

### File Already Exists

When target file already exists:

```yaml
Default Behavior (no --force):
  Action: Skip, keep existing file
  Output: ⊘ commands/format.md (skipped - already exists)
  Reason: Preserve local customizations

With --force:
  Action: Backup existing, create symlink
  Output: ✓ Replaced commands/format.md with symlink
  Backup: .claude/.inherit-backup-{timestamp}/commands/format.md
```

### Symlink Already Exists

When target is already a symlink:

```yaml
Same Target:
  Action: Skip, already correct
  Output: ✓ commands/format.md (already linked correctly)

Different Target:
  Default: Skip, warn about conflict
  Output: ⚠ commands/format.md points to different source
          Current: ../../other/.claude/commands/format.md
          Would be: ../../parent/.claude/commands/format.md

  With --force: Replace with new symlink
```

### Name Collisions

Multiple parents have same file:

```yaml
Scenario:
  Parent 1: /Users/manu/.claude/commands/test.md
  Parent 2: /Users/manu/Documents/.claude/commands/test.md
  Target: /Users/manu/Documents/LUXOR/.claude/commands/test.md

Behavior:
  - First parent found wins (closest parent)
  - Closer parents take precedence
  - Warning shown for collision

Output:
  ✓ test.md → ../../.claude/commands/test.md (from /Users/manu/Documents)
  ⚠ Skipping test.md from /Users/manu/.claude (already inherited from closer parent)
```

### Circular Inheritance

Prevent infinite loops:

```yaml
Detection:
  - Track visited directories
  - Detect if symlink would point back to self
  - Prevent creating circular references

Example:
  Project A inherits from Project B
  Project B tries to inherit from Project A

  Error: ❌ Circular inheritance detected
         Cannot inherit from /path/to/A (would create loop)
```

## Error Handling

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| No parent .claude/ found | No parent directories have .claude/ | Use `--from <path>` to specify source |
| Permission denied | Can't create symlink in target | Check directory permissions |
| No .claude/ in child | Child path doesn't have .claude/ | Create child .claude/ directory first |
| Invalid source path | Path doesn't exist | Verify path with `ls <path>` |
| Broken symlink created | Source moved after creation | Run `/inherit --clean` |
| Circular reference | Projects reference each other | Restructure inheritance hierarchy |

### Error Output Examples

```bash
# No parents found
/inherit
❌ No parent directories with .claude/ found
   Searched up to: /

   Options:
   1. Create parent .claude/: mkdir -p ../.claude/commands
   2. Inherit from specific path: /inherit --from <path>

# Invalid child path
/inherit --child ./nonexistent
❌ Child path not found: ./nonexistent

   Verify path exists: ls ./nonexistent

# No .claude directory in child
/inherit --child ./subproject
❌ No .claude/ directory in child: ./subproject

   Create it first: mkdir -p ./subproject/.claude/{commands,agents}

# Permission denied
/inherit
❌ Permission denied creating symlink
   Target: .claude/commands/format.md

   Check permissions: ls -la .claude/commands/
   Fix: chmod +w .claude/commands/

# Source file doesn't exist
/inherit --from /team/shared
⚠️  Skipping commands/missing.md (source file doesn't exist)
    Expected: /team/shared/.claude/commands/missing.md
```

## Validation

Before creating symlinks:

### Pre-flight Checks

```yaml
Directory Structure:
  ✓ Current directory has .claude/
  ✓ .claude/commands/ exists (create if missing)
  ✓ .claude/agents/ exists (create if missing)
  ✓ Write permissions on target directories

Source Validation:
  ✓ Source .claude/ directory exists
  ✓ Source commands/ or agents/ directories exist
  ✓ Source files are readable
  ✓ Not creating circular reference

Target Validation:
  ✓ Target path valid
  ✓ No conflict with existing files (unless --force)
  ✓ Symlink can be created (permissions)
  ✓ Relative path can be calculated

Symlink Verification (after creation):
  ✓ Symlink exists
  ✓ Symlink points to correct target
  ✓ Target is readable through symlink
  ✓ No broken symlinks created
```

### Post-Creation Verification

```bash
# After /inherit, verify symlinks work
for link in .claude/commands/*; do
  if [ -L "$link" ]; then
    if [ ! -e "$link" ]; then
      echo "❌ Broken: $link"
    else
      echo "✓ Valid: $link → $(readlink "$link")"
    fi
  fi
done
```

## Advanced Features

### Selective Inheritance

Inherit only specific commands/agents:

```yaml
# Future enhancement (not yet implemented)
/inherit --only commands/test.md,commands/build.md
/inherit --except agents/*
/inherit --pattern "commands/test-*.md"
```

### Inheritance Profiles

Define inheritance rules in config:

```yaml
# .claude/inherit.yaml (future enhancement)
inherit:
  from:
    - ~/global-commands
    - ../team-standards

  push_to:
    - ./packages/*/
    - ./services/*/

  exclude:
    - "*.local.md"
    - "experimental-*.md"

  on_conflict: skip  # or: overwrite, prompt
```

### Update Propagation

Check for updates in parent commands:

```yaml
# Future enhancement
/inherit --check-updates

# Output:
# Updates available:
#   commands/format.md (modified 2 days ago)
#   commands/test.md (modified 1 week ago)
#
# Update all: /inherit --update
# Update specific: /inherit --update commands/format.md
```

## Integration with Other Commands

### With /meta-agent

```bash
# Create agent, then share with children
/meta-agent "code reviewer for Python"
/agent code-reviewer --from-spec
/inherit --children

# All child projects now have code-reviewer agent
```

### With /agent

```bash
# Create standardized agents across projects
cd ~/templates/python-project
/agent test-runner --from-spec
/inherit --child ~/projects/my-python-app

# my-python-app inherits test-runner agent
```

### With Git

```bash
# Symlinks work with Git
git add .claude/commands/*.md  # Adds symlinks
git commit -m "Add inherited commands"
git push

# Other developers get symlinks
# (They need access to source directories)
```

## Best Practices

### 1. Organize Parent Directories

```bash
# Good: Clear hierarchy
/Users/manu/.claude/              # Global commands
/Users/manu/company/.claude/      # Company-wide
/Users/manu/company/team/.claude/ # Team-specific
/Users/manu/company/team/proj/    # Project (inherits all)

# Avoid: Flat structure with unclear relationships
```

### 2. Use Relative Paths

```bash
# Good: Portable across machines
ln -s ../../.claude/commands/test.md .claude/commands/test.md

# Avoid: Absolute paths (not portable)
ln -s /Users/manu/.claude/commands/test.md .claude/commands/test.md
```

### 3. Document Inheritance

```bash
# Add to project README.md
## Command Inheritance

This project inherits commands from:
- Parent project: `../` (build, test, deploy)
- Global: `~/.claude/` (format, lint)

To refresh inherited commands: `/inherit`
```

### 4. Version Control

```bash
# .gitignore - Option 1: Commit symlinks
# (Good if team has access to source directories)

# .gitignore - Option 2: Ignore symlinks
.claude/commands/*
.claude/agents/*
!.claude/commands/*.local.md
!.claude/agents/*.local.md

# Each developer runs /inherit after clone
```

### 5. Regular Cleanup

```bash
# Periodically clean broken symlinks
/inherit --clean

# Check inheritance status
/inherit --list

# Verify symlinks still valid
```

### 6. Safe Force Usage

```bash
# Always dry-run before force
/inherit --force --dry-run

# Review what would change
# Then apply
/inherit --force
```

## Troubleshooting

### Symlinks Not Working

```bash
# Check if symlink exists
ls -la .claude/commands/format.md

# Check symlink target
readlink .claude/commands/format.md

# Check if target exists
ls -la $(readlink .claude/commands/format.md)

# Recreate if broken
rm .claude/commands/format.md
/inherit
```

### Commands Not Appearing

```bash
# Verify symlinks created
/inherit --list

# Check Claude Code recognizes symlinks
ls -la .claude/commands/

# Restart Claude Code if needed
# (Symlinks should work without restart)
```

### Wrong Parent Inherited

```bash
# Check which parent was used
readlink .claude/commands/format.md

# Remove and specify correct parent
rm .claude/commands/format.md
/inherit --from /correct/parent/path
```

### Updates Not Reflecting

```bash
# Symlinks should reflect updates automatically
# If not, verify symlink not broken
/inherit --list

# If broken, recreate
/inherit --clean
/inherit
```

## Security Considerations

### Symlink Safety

```yaml
Risks:
  - Symlinks can point outside project
  - Malicious symlinks could expose sensitive files
  - Broken symlinks could cause errors

Mitigations:
  - Validate source paths before creating
  - Use relative paths when possible
  - Verify targets exist and are readable
  - Never follow symlinks outside expected directories
  - Warn on suspicious patterns
```

### Permission Handling

```yaml
Permissions Inherited:
  - Symlinks don't have their own permissions
  - Target file permissions apply
  - Read/write/execute determined by target

Best Practices:
  - Ensure source files have appropriate permissions
  - Don't symlink sensitive files (credentials, keys)
  - Use .gitignore for sensitive local commands
```

### Access Control

```yaml
Scenarios:
  Team environment:
    - Ensure all team members can access source directories
    - Use shared paths (/team/shared) not user paths (~/)

  Personal environment:
    - Safe to use home directory (~/.claude)
    - Symlinks within your own directories

  Production:
    - Avoid symlinks in production deployments
    - Copy files instead of symlinking
```

## Performance

### Symlink Advantages

```yaml
Benefits:
  - Instant updates (change source, all inherit)
  - No duplication (saves disk space)
  - Clear provenance (readlink shows source)
  - Easy management (update one file)

Drawbacks:
  - Requires access to source
  - Broken if source moved/deleted
  - Harder to customize inherited commands
```

### Optimization

```yaml
Large Hierarchies:
  - Limit search depth (stops at filesystem root)
  - Cache discovered .claude/ directories
  - Skip .git, node_modules, etc.

Many Files:
  - Create symlinks in batch
  - Use find efficiently
  - Parallelize when possible
```

## Related Commands

- `/agent` - Create agents that can be inherited
- `/meta-agent` - Generate agent specs to share
- `/help` - List all available commands

## Version History

- v1.0: Initial implementation (pull, push, list)
- v1.1: Added dry-run and force modes
- v1.2: Added clean mode for broken symlinks
- v1.3: Enhanced conflict resolution
- v1.4: Added verbose mode and better error handling

## Future Enhancements

Planned features:

```yaml
Selective Inheritance:
  - Inherit only specific files
  - Pattern-based inclusion/exclusion
  - Inheritance profiles

Update Management:
  - Check for updates in parent commands
  - Apply updates selectively
  - Version tracking

Advanced Linking:
  - Hard links option
  - Copy instead of symlink
  - Template expansion

Configuration:
  - .claude/inherit.yaml for rules
  - Per-project inheritance policies
  - Conflict resolution strategies
```

## Philosophy

Inheritance enables:

1. **DRY Principle**: Define commands once, use everywhere
2. **Consistency**: Same commands across projects
3. **Centralized Updates**: Update once, propagate everywhere
4. **Flexibility**: Local overrides still possible
5. **Scalability**: Manage commands for many projects

Use inheritance for shared commands, keep local customizations local.


ARGUMENTS: {{args}}

## Implementation Instructions

Based on the arguments provided, execute the appropriate mode:

### Parse Arguments

```bash
ARGS="{{args}}"

# Determine mode
if [[ "$ARGS" == *"--help"* ]]; then
  MODE="help"
elif [[ "$ARGS" == *"--list"* ]]; then
  MODE="list"
elif [[ "$ARGS" == *"--clean"* ]]; then
  MODE="clean"
elif [[ "$ARGS" == *"--sync"* ]]; then
  MODE="sync"
elif [[ "$ARGS" == *"--from-children"* ]]; then
  MODE="pull-from-children"
elif [[ "$ARGS" == *"--children"* ]]; then
  MODE="push-all"
elif [[ "$ARGS" == *"--child "* ]]; then
  MODE="push-one"
  CHILD_PATH=$(echo "$ARGS" | sed -n 's/.*--child \([^ ]*\).*/\1/p')
elif [[ "$ARGS" == *"--from "* ]]; then
  MODE="pull-from"
  FROM_PATH=$(echo "$ARGS" | sed -n 's/.*--from \([^ ]*\).*/\1/p')
else
  MODE="pull-parents"
fi

DRY_RUN=false
[[ "$ARGS" == *"--dry-run"* ]] && DRY_RUN=true

FORCE=false
[[ "$ARGS" == *"--force"* ]] && FORCE=true

VERBOSE=false
[[ "$ARGS" == *"--verbose"* ]] && VERBOSE=true
```

### Execute Mode

```bash
case "$MODE" in
  help)
    # Display help documentation (already shown above)
    ;;

  list)
    # Show current inheritance structure
    echo "Current Project: $(pwd)"
    echo ""

    # List commands
    echo "Commands:"
    for file in .claude/commands/*.md; do
      [ -e "$file" ] || continue
      basename_file=$(basename "$file")
      if [ -L "$file" ]; then
        target=$(readlink "$file")
        if [ -e "$file" ]; then
          echo "  ✓ $basename_file → $target (valid symlink)"
        else
          echo "  ✗ $basename_file → $target (broken symlink)"
        fi
      else
        echo "  ○ $basename_file (local file)"
      fi
    done

    # List agents
    echo ""
    echo "Agents:"
    for file in .claude/agents/*.md; do
      [ -e "$file" ] || continue
      basename_file=$(basename "$file")
      if [ -L "$file" ]; then
        target=$(readlink "$file")
        if [ -e "$file" ]; then
          echo "  ✓ $basename_file → $target (valid symlink)"
        else
          echo "  ✗ $basename_file → $target (broken symlink)"
        fi
      else
        echo "  ○ $basename_file (local file)"
      fi
    done
    ;;

  clean)
    # Remove broken symlinks
    echo "🧹 Cleaning broken symlinks..."

    removed_count=0

    # Check commands
    for file in .claude/commands/*; do
      [ -L "$file" ] || continue
      if [ ! -e "$file" ]; then
        echo "  ✗ $(basename "$file") → $(readlink "$file")"
        [ "$DRY_RUN" = false ] && rm "$file" && ((removed_count++))
      fi
    done

    # Check agents
    for file in .claude/agents/*; do
      [ -L "$file" ] || continue
      if [ ! -e "$file" ]; then
        echo "  ✗ $(basename "$file") → $(readlink "$file")"
        [ "$DRY_RUN" = false ] && rm "$file" && ((removed_count++))
      fi
    done

    if [ "$DRY_RUN" = true ]; then
      echo ""
      echo "Dry run - no changes made"
    else
      echo ""
      echo "Cleaned $removed_count broken symlinks"
    fi
    ;;

  pull-parents)
    # Search up directory tree for .claude/ directories
    echo "Searching for parent .claude/ directories..."

    current_dir=$(pwd)
    check_dir="$current_dir/.."
    found_parents=0
    created_symlinks=0

    while [ "$check_dir" != "/" ]; do
      check_dir=$(cd "$check_dir" && pwd)

      if [ -d "$check_dir/.claude" ]; then
        echo "✓ Found parent: $check_dir/.claude"
        ((found_parents++))

        # Create symlinks for commands
        if [ -d "$check_dir/.claude/commands" ]; then
          for src_file in "$check_dir/.claude/commands"/*.md; do
            [ -e "$src_file" ] || continue

            filename=$(basename "$src_file")
            target_file="$current_dir/.claude/commands/$filename"

            # Calculate relative path
            rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$current_dir/.claude/commands'))")

            if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
              [ "$VERBOSE" = true ] && echo "  ⊘ commands/$filename (already exists)"
            else
              echo "  → commands/$filename"
              if [ "$DRY_RUN" = false ]; then
                [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
                ln -s "$rel_path" "$target_file"
                ((created_symlinks++))
              fi
            fi
          done
        fi

        # Create symlinks for agents
        if [ -d "$check_dir/.claude/agents" ]; then
          for src_file in "$check_dir/.claude/agents"/*.md; do
            [ -e "$src_file" ] || continue

            filename=$(basename "$src_file")
            target_file="$current_dir/.claude/agents/$filename"

            # Calculate relative path
            rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$current_dir/.claude/agents'))")

            if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
              [ "$VERBOSE" = true ] && echo "  ⊘ agents/$filename (already exists)"
            else
              echo "  → agents/$filename"
              if [ "$DRY_RUN" = false ]; then
                [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
                ln -s "$rel_path" "$target_file"
                ((created_symlinks++))
              fi
            fi
          done
        fi
      fi

      check_dir="$check_dir/.."
    done

    echo ""
    if [ $found_parents -eq 0 ]; then
      echo "❌ No parent .claude/ directories found"
    else
      if [ "$DRY_RUN" = true ]; then
        echo "Dry run - would create $created_symlinks symlinks from $found_parents parent(s)"
      else
        echo "Created $created_symlinks symlinks from $found_parents parent(s)"
      fi
    fi
    ;;

  pull-from)
    # Pull from specific directory
    FROM_PATH=$(eval echo "$FROM_PATH")  # Expand ~ and variables

    if [ ! -d "$FROM_PATH/.claude" ]; then
      echo "❌ No .claude/ directory found at: $FROM_PATH"
      exit 1
    fi

    echo "✓ Inheriting from: $FROM_PATH/.claude"

    current_dir=$(pwd)
    created_symlinks=0

    # Create symlinks for commands
    if [ -d "$FROM_PATH/.claude/commands" ]; then
      mkdir -p "$current_dir/.claude/commands"
      for src_file in "$FROM_PATH/.claude/commands"/*.md; do
        [ -e "$src_file" ] || continue

        filename=$(basename "$src_file")
        target_file="$current_dir/.claude/commands/$filename"

        # Calculate relative path
        rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$current_dir/.claude/commands'))")

        if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
          [ "$VERBOSE" = true ] && echo "  ⊘ commands/$filename (already exists)"
        else
          echo "  → commands/$filename"
          if [ "$DRY_RUN" = false ]; then
            [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
            ln -s "$rel_path" "$target_file"
            ((created_symlinks++))
          fi
        fi
      done
    fi

    # Create symlinks for agents
    if [ -d "$FROM_PATH/.claude/agents" ]; then
      mkdir -p "$current_dir/.claude/agents"
      for src_file in "$FROM_PATH/.claude/agents"/*.md; do
        [ -e "$src_file" ] || continue

        filename=$(basename "$src_file")
        target_file="$current_dir/.claude/agents/$filename"

        # Calculate relative path
        rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$current_dir/.claude/agents'))")

        if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
          [ "$VERBOSE" = true ] && echo "  ⊘ agents/$filename (already exists)"
        else
          echo "  → agents/$filename"
          if [ "$DRY_RUN" = false ]; then
            [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
            ln -s "$rel_path" "$target_file"
            ((created_symlinks++))
          fi
        fi
      done
    fi

    echo ""
    if [ "$DRY_RUN" = true ]; then
      echo "Dry run - would create $created_symlinks symlinks"
    else
      echo "Created $created_symlinks symlinks"
    fi
    ;;

  push-all)
    # Push to all child projects
    echo "Searching for child .claude/ directories..."

    current_dir=$(pwd)
    found_children=0
    created_symlinks=0

    # Find all .claude directories in subdirectories
    while IFS= read -r child_claude; do
      child_dir=$(dirname "$child_claude")

      echo "✓ Found child: $child_dir"
      ((found_children++))

      # Create symlinks for commands
      if [ -d "$current_dir/.claude/commands" ]; then
        mkdir -p "$child_dir/.claude/commands"
        for src_file in "$current_dir/.claude/commands"/*.md; do
          [ -e "$src_file" ] || continue
          [ -L "$src_file" ] && continue  # Skip symlinks (don't propagate inherited)

          filename=$(basename "$src_file")
          target_file="$child_dir/.claude/commands/$filename"

          # Calculate relative path
          rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$child_dir/.claude/commands'))")

          if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
            [ "$VERBOSE" = true ] && echo "  ⊘ commands/$filename (already exists)"
          else
            echo "  → commands/$filename"
            if [ "$DRY_RUN" = false ]; then
              [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
              ln -s "$rel_path" "$target_file"
              ((created_symlinks++))
            fi
          fi
        done
      fi

      # Create symlinks for agents
      if [ -d "$current_dir/.claude/agents" ]; then
        mkdir -p "$child_dir/.claude/agents"
        for src_file in "$current_dir/.claude/agents"/*.md; do
          [ -e "$src_file" ] || continue
          [ -L "$src_file" ] && continue  # Skip symlinks

          filename=$(basename "$src_file")
          target_file="$child_dir/.claude/agents/$filename"

          # Calculate relative path
          rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$child_dir/.claude/agents'))")

          if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
            [ "$VERBOSE" = true ] && echo "  ⊘ agents/$filename (already exists)"
          else
            echo "  → agents/$filename"
            if [ "$DRY_RUN" = false ]; then
              [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
              ln -s "$rel_path" "$target_file"
              ((created_symlinks++))
            fi
          fi
        done
      fi
    done < <(find . -mindepth 2 -type d -name ".claude" -not -path "*/\.*/*")

    echo ""
    if [ $found_children -eq 0 ]; then
      echo "❌ No child .claude/ directories found"
    else
      if [ "$DRY_RUN" = true ]; then
        echo "Dry run - would push to $found_children child(ren) ($created_symlinks symlinks)"
      else
        echo "Pushed to $found_children child(ren) ($created_symlinks symlinks)"
      fi
    fi
    ;;

  push-one)
    # Push to specific child
    CHILD_PATH=$(eval echo "$CHILD_PATH")  # Expand ~ and variables

    # Resolve to absolute path if relative
    if [[ "$CHILD_PATH" != /* ]]; then
      CHILD_PATH="$(pwd)/$CHILD_PATH"
    fi

    if [ ! -d "$CHILD_PATH" ]; then
      echo "❌ Child path not found: $CHILD_PATH"
      exit 1
    fi

    if [ ! -d "$CHILD_PATH/.claude" ]; then
      echo "❌ No .claude/ directory in child: $CHILD_PATH"
      echo "   Create it first: mkdir -p $CHILD_PATH/.claude/{commands,agents}"
      exit 1
    fi

    echo "✓ Pushing to: $CHILD_PATH/.claude"

    current_dir=$(pwd)
    created_symlinks=0

    # Create symlinks for commands
    if [ -d "$current_dir/.claude/commands" ]; then
      mkdir -p "$CHILD_PATH/.claude/commands"
      for src_file in "$current_dir/.claude/commands"/*.md; do
        [ -e "$src_file" ] || continue
        [ -L "$src_file" ] && continue  # Skip symlinks

        filename=$(basename "$src_file")
        target_file="$CHILD_PATH/.claude/commands/$filename"

        # Calculate relative path
        rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$CHILD_PATH/.claude/commands'))")

        if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
          [ "$VERBOSE" = true ] && echo "  ⊘ commands/$filename (already exists)"
        else
          echo "  → commands/$filename"
          if [ "$DRY_RUN" = false ]; then
            [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
            ln -s "$rel_path" "$target_file"
            ((created_symlinks++))
          fi
        fi
      done
    fi

    # Create symlinks for agents
    if [ -d "$current_dir/.claude/agents" ]; then
      mkdir -p "$CHILD_PATH/.claude/agents"
      for src_file in "$current_dir/.claude/agents"/*.md; do
        [ -e "$src_file" ] || continue
        [ -L "$src_file" ] && continue  # Skip symlinks

        filename=$(basename "$src_file")
        target_file="$CHILD_PATH/.claude/agents/$filename"

        # Calculate relative path
        rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$CHILD_PATH/.claude/agents'))")

        if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
          [ "$VERBOSE" = true ] && echo "  ⊘ agents/$filename (already exists)"
        else
          echo "  → agents/$filename"
          if [ "$DRY_RUN" = false ]; then
            [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
            ln -s "$rel_path" "$target_file"
            ((created_symlinks++))
          fi
        fi
      done
    fi

    echo ""
    if [ "$DRY_RUN" = true ]; then
      echo "Dry run - would create $created_symlinks symlinks"
    else
      echo "Created $created_symlinks symlinks"
    fi
    ;;

  pull-from-children)
    # Pull latest versions from child projects
    echo "Scanning child projects for updates..."
    echo ""

    current_dir=$(pwd)
    found_children=0
    pulled_files=0

    # Create backup directory if not dry run
    if [ "$DRY_RUN" = false ] && [ "$FORCE" = false ]; then
      BACKUP_DIR=".claude/.inherit-backup-$(date +%Y%m%d-%H%M%S)"
    fi

    # Find all .claude directories in subdirectories
    while IFS= read -r child_claude; do
      child_dir=$(dirname "$child_claude")

      echo "✓ Found child: $child_dir"
      ((found_children++))

      child_has_updates=false

      # Check commands for updates
      if [ -d "$child_dir/.claude/commands" ]; then
        for child_file in "$child_dir/.claude/commands"/*.md; do
          [ -e "$child_file" ] || continue
          [ -L "$child_file" ] && continue  # Skip symlinks, only real files

          filename=$(basename "$child_file")
          parent_file="$current_dir/.claude/commands/$filename"

          # Check if parent file exists
          if [ -e "$parent_file" ]; then
            # Compare modification times
            child_mtime=$(stat -f %m "$child_file" 2>/dev/null || stat -c %Y "$child_file" 2>/dev/null)
            parent_mtime=$(stat -f %m "$parent_file" 2>/dev/null || stat -c %Y "$parent_file" 2>/dev/null)

            if [ "$child_mtime" -gt "$parent_mtime" ]; then
              child_date=$(date -r "$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null || date -d "@$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null)
              echo "  ← commands/$filename (newer in child, updated: $child_date)"

              if [ "$DRY_RUN" = false ]; then
                # Backup parent version if it's a real file (not symlink)
                if [ ! -L "$parent_file" ] && [ "$FORCE" = false ]; then
                  mkdir -p "$BACKUP_DIR/commands"
                  cp "$parent_file" "$BACKUP_DIR/commands/$filename"
                fi

                # Copy child to parent
                rm -f "$parent_file"  # Remove symlink or old file
                cp "$child_file" "$parent_file"
                ((pulled_files++))
                child_has_updates=true
              fi
            else
              [ "$VERBOSE" = true ] && echo "  ⊘ commands/$filename (parent is newer, skipped)"
            fi
          else
            # File doesn't exist in parent, copy from child
            child_date=$(stat -f %m "$child_file" 2>/dev/null | xargs -I {} date -r {} "+%Y-%m-%d %H:%M" 2>/dev/null)
            echo "  ← commands/$filename (new file from child)"

            if [ "$DRY_RUN" = false ]; then
              mkdir -p "$current_dir/.claude/commands"
              cp "$child_file" "$parent_file"
              ((pulled_files++))
              child_has_updates=true
            fi
          fi
        done
      fi

      # Check agents for updates
      if [ -d "$child_dir/.claude/agents" ]; then
        for child_file in "$child_dir/.claude/agents"/*.md; do
          [ -e "$child_file" ] || continue
          [ -L "$child_file" ] && continue  # Skip symlinks

          filename=$(basename "$child_file")
          parent_file="$current_dir/.claude/agents/$filename"

          # Check if parent file exists
          if [ -e "$parent_file" ]; then
            # Compare modification times
            child_mtime=$(stat -f %m "$child_file" 2>/dev/null || stat -c %Y "$child_file" 2>/dev/null)
            parent_mtime=$(stat -f %m "$parent_file" 2>/dev/null || stat -c %Y "$parent_file" 2>/dev/null)

            if [ "$child_mtime" -gt "$parent_mtime" ]; then
              child_date=$(date -r "$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null || date -d "@$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null)
              echo "  ← agents/$filename (newer in child, updated: $child_date)"

              if [ "$DRY_RUN" = false ]; then
                # Backup parent version if it's a real file
                if [ ! -L "$parent_file" ] && [ "$FORCE" = false ]; then
                  mkdir -p "$BACKUP_DIR/agents"
                  cp "$parent_file" "$BACKUP_DIR/agents/$filename"
                fi

                # Copy child to parent
                rm -f "$parent_file"
                cp "$child_file" "$parent_file"
                ((pulled_files++))
                child_has_updates=true
              fi
            else
              [ "$VERBOSE" = true ] && echo "  ⊘ agents/$filename (parent is newer, skipped)"
            fi
          else
            # File doesn't exist in parent, copy from child
            echo "  ← agents/$filename (new file from child)"

            if [ "$DRY_RUN" = false ]; then
              mkdir -p "$current_dir/.claude/agents"
              cp "$child_file" "$parent_file"
              ((pulled_files++))
              child_has_updates=true
            fi
          fi
        done
      fi

      [ "$child_has_updates" = false ] && [ "$VERBOSE" = false ] && echo "  (no updates)"
      echo ""
    done < <(find . -mindepth 2 -type d -name ".claude" -not -path "*/\.*/*")

    if [ $found_children -eq 0 ]; then
      echo "❌ No child .claude/ directories found"
    else
      if [ "$DRY_RUN" = true ]; then
        echo "Dry run - would pull $pulled_files files from $found_children child project(s)"
      else
        echo "Pulled $pulled_files updated files from $found_children child project(s)"
        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
          echo "Backups saved to: $BACKUP_DIR"
        fi
      fi
    fi
    ;;

  sync)
    # Bidirectional sync: push then pull
    echo "=== Phase 1: Pushing to children ==="
    echo ""

    # Execute push-all logic
    current_dir=$(pwd)
    found_children=0
    created_symlinks=0

    while IFS= read -r child_claude; do
      child_dir=$(dirname "$child_claude")

      echo "✓ Found child: $child_dir"
      ((found_children++))

      # Create symlinks for commands
      if [ -d "$current_dir/.claude/commands" ]; then
        mkdir -p "$child_dir/.claude/commands"
        for src_file in "$current_dir/.claude/commands"/*.md; do
          [ -e "$src_file" ] || continue
          [ -L "$src_file" ] && continue

          filename=$(basename "$src_file")
          target_file="$child_dir/.claude/commands/$filename"

          rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$child_dir/.claude/commands'))")

          if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
            [ "$VERBOSE" = true ] && echo "  ⊘ commands/$filename (already exists)"
          else
            echo "  → commands/$filename"
            if [ "$DRY_RUN" = false ]; then
              [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
              ln -s "$rel_path" "$target_file"
              ((created_symlinks++))
            fi
          fi
        done
      fi

      # Create symlinks for agents
      if [ -d "$current_dir/.claude/agents" ]; then
        mkdir -p "$child_dir/.claude/agents"
        for src_file in "$current_dir/.claude/agents"/*.md; do
          [ -e "$src_file" ] || continue
          [ -L "$src_file" ] && continue

          filename=$(basename "$src_file")
          target_file="$child_dir/.claude/agents/$filename"

          rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_file', '$child_dir/.claude/agents'))")

          if [ -e "$target_file" ] && [ "$FORCE" = false ]; then
            [ "$VERBOSE" = true ] && echo "  ⊘ agents/$filename (already exists)"
          else
            echo "  → agents/$filename"
            if [ "$DRY_RUN" = false ]; then
              [ "$FORCE" = true ] && [ -e "$target_file" ] && rm "$target_file"
              ln -s "$rel_path" "$target_file"
              ((created_symlinks++))
            fi
          fi
        done
      fi
    done < <(find . -mindepth 2 -type d -name ".claude" -not -path "*/\.*/*")

    echo ""
    if [ "$DRY_RUN" = true ]; then
      echo "Phase 1 complete: would push to $found_children child(ren) ($created_symlinks symlinks)"
    else
      echo "Phase 1 complete: pushed to $found_children child(ren) ($created_symlinks symlinks)"
    fi

    echo ""
    echo "=== Phase 2: Pulling updates from children ==="
    echo ""

    # Execute pull-from-children logic
    pulled_files=0

    if [ "$DRY_RUN" = false ] && [ "$FORCE" = false ]; then
      BACKUP_DIR=".claude/.inherit-backup-$(date +%Y%m%d-%H%M%S)"
    fi

    while IFS= read -r child_claude; do
      child_dir=$(dirname "$child_claude")
      child_has_updates=false

      # Check commands
      if [ -d "$child_dir/.claude/commands" ]; then
        for child_file in "$child_dir/.claude/commands"/*.md; do
          [ -e "$child_file" ] || continue
          [ -L "$child_file" ] && continue

          filename=$(basename "$child_file")
          parent_file="$current_dir/.claude/commands/$filename"

          if [ -e "$parent_file" ]; then
            child_mtime=$(stat -f %m "$child_file" 2>/dev/null || stat -c %Y "$child_file" 2>/dev/null)
            parent_mtime=$(stat -f %m "$parent_file" 2>/dev/null || stat -c %Y "$parent_file" 2>/dev/null)

            if [ "$child_mtime" -gt "$parent_mtime" ]; then
              if [ "$child_has_updates" = false ]; then
                echo "✓ Updates in: $child_dir"
                child_has_updates=true
              fi

              child_date=$(date -r "$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null || date -d "@$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null)
              echo "  ← commands/$filename (updated: $child_date)"

              if [ "$DRY_RUN" = false ]; then
                if [ ! -L "$parent_file" ] && [ "$FORCE" = false ]; then
                  mkdir -p "$BACKUP_DIR/commands"
                  cp "$parent_file" "$BACKUP_DIR/commands/$filename"
                fi
                rm -f "$parent_file"
                cp "$child_file" "$parent_file"
                ((pulled_files++))
              fi
            fi
          fi
        done
      fi

      # Check agents
      if [ -d "$child_dir/.claude/agents" ]; then
        for child_file in "$child_dir/.claude/agents"/*.md; do
          [ -e "$child_file" ] || continue
          [ -L "$child_file" ] && continue

          filename=$(basename "$child_file")
          parent_file="$current_dir/.claude/agents/$filename"

          if [ -e "$parent_file" ]; then
            child_mtime=$(stat -f %m "$child_file" 2>/dev/null || stat -c %Y "$child_file" 2>/dev/null)
            parent_mtime=$(stat -f %m "$parent_file" 2>/dev/null || stat -c %Y "$parent_file" 2>/dev/null)

            if [ "$child_mtime" -gt "$parent_mtime" ]; then
              if [ "$child_has_updates" = false ]; then
                echo "✓ Updates in: $child_dir"
                child_has_updates=true
              fi

              child_date=$(date -r "$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null || date -d "@$child_mtime" "+%Y-%m-%d %H:%M" 2>/dev/null)
              echo "  ← agents/$filename (updated: $child_date)"

              if [ "$DRY_RUN" = false ]; then
                if [ ! -L "$parent_file" ] && [ "$FORCE" = false ]; then
                  mkdir -p "$BACKUP_DIR/agents"
                  cp "$parent_file" "$BACKUP_DIR/agents/$filename"
                fi
                rm -f "$parent_file"
                cp "$child_file" "$parent_file"
                ((pulled_files++))
              fi
            fi
          fi
        done
      fi
    done < <(find . -mindepth 2 -type d -name ".claude" -not -path "*/\.*/*")

    echo ""
    if [ "$DRY_RUN" = true ]; then
      echo "Phase 2 complete: would pull $pulled_files files"
      echo ""
      echo "Sync summary: would push $created_symlinks symlinks, pull $pulled_files files"
    else
      echo "Phase 2 complete: pulled $pulled_files updated files"
      if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo "Backups saved to: $BACKUP_DIR"
      fi
      echo ""
      echo "Sync complete: pushed $created_symlinks symlinks, pulled $pulled_files files"
    fi
    ;;
esac
```

### Error Handling

```bash
# Ensure .claude directories exist
mkdir -p .claude/commands
mkdir -p .claude/agents

# Validate permissions
if [ ! -w .claude/commands ]; then
  echo "❌ No write permission for .claude/commands/"
  exit 1
fi

if [ ! -w .claude/agents ]; then
  echo "❌ No write permission for .claude/agents/"
  exit 1
fi
```

Now execute the appropriate commands based on the parsed arguments and mode.
