#!/bin/bash
# Behavioral regression test for C07: ((count++)) under `set -e` aborted
# every installer after the first skill (post-increment of 0 returns a
# 0-valued arithmetic expression -> exit status 1 -> set -e kills the script).
#
# Proves two things:
#   1. The patched install.sh scripts install ALL declared skills and exit 0.
#   2. The pre-fix install.sh (from main) really did abort after skill #1,
#      so this test fails on the buggy code (it is not a tautology).
#
# Usage: bash tests/test_install_counter.sh   (from repo root)

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
pass() { echo "PASS: $1"; PASS=$((PASS+1)); }

run_installer() {
    # $1 = plugin dir, $2 = script path; runs with an isolated fake HOME.
    # Echoes "exit_code installed_count" on stdout.
    local plugin_dir="$1" script="$2"
    local fake_home
    fake_home="$(mktemp -d)"
    mkdir -p "$fake_home/.claude"
    ( cd "$plugin_dir" && HOME="$fake_home" bash "$script" >/dev/null 2>&1 )
    local rc=$?
    local installed
    installed=$(find "$fake_home/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    rm -rf "$fake_home"
    echo "$rc $installed"
}

declared_skills() {
    # Count skills the installer declares AND that exist on disk (what a
    # correct run must install).
    local plugin_dir="$1"
    local n=0 skill
    while IFS= read -r skill; do
        [ -d "$plugin_dir/skills/$skill" ] && n=$((n+1))
    done < <(sed -n '/^SKILLS=(/,/^)/p' "$plugin_dir/install.sh" | grep -o '"[^"]*"' | tr -d '"')
    echo "$n"
}

echo "=== 1. Negative control: pre-fix installer (from main) must abort after skill #1 ==="
BUGGY_PLUGIN="$REPO_ROOT/plugins/luxor-ai-integration"
BUGGY_SCRIPT="$(mktemp /tmp/buggy-install-XXXXXX.sh)"
if git -C "$REPO_ROOT" show main:plugins/luxor-ai-integration/install.sh > "$BUGGY_SCRIPT" 2>/dev/null; then
    if grep -q '((count++))' "$BUGGY_SCRIPT"; then
        read -r rc installed <<< "$(run_installer "$BUGGY_PLUGIN" "$BUGGY_SCRIPT")"
        if [ "$rc" -ne 0 ] && [ "$installed" -eq 1 ]; then
            pass "buggy main installer aborted after 1 skill (exit=$rc, installed=$installed) — test detects the bug"
        else
            fail "buggy main installer did NOT reproduce the abort (exit=$rc, installed=$installed)"
        fi
    else
        fail "main copy of install.sh no longer contains ((count++)); negative control invalid"
    fi
else
    fail "could not extract pre-fix install.sh from main"
fi
rm -f "$BUGGY_SCRIPT"

echo ""
echo "=== 2. Patched installers: every declared skill installs, exit 0 ==="
TESTED=0
for plugin_dir in "$REPO_ROOT"/plugins/*/; do
    plugin="$(basename "$plugin_dir")"
    [ -f "$plugin_dir/install.sh" ] || continue
    grep -q '^SKILLS=(' "$plugin_dir/install.sh" || continue   # skill-builder uses glob loops, not the counter idiom
    expected="$(declared_skills "$plugin_dir")"
    if [ "$expected" -lt 2 ]; then
        fail "$plugin: only $expected on-disk declared skills — cannot prove multi-skill progress"
        continue
    fi
    TESTED=$((TESTED+1))
    read -r rc installed <<< "$(run_installer "$plugin_dir" "$plugin_dir/install.sh")"
    if [ "$rc" -eq 0 ] && [ "$installed" -eq "$expected" ]; then
        pass "$plugin: exit=0, installed $installed/$expected skills"
    else
        fail "$plugin: exit=$rc, installed $installed/$expected skills"
    fi
done
[ "$TESTED" -ge 9 ] || fail "expected to exercise >=9 plugins, only ran $TESTED"

echo ""
echo "=== 3. Regression guard: no ((count++)) anywhere in plugin scripts ==="
if grep -rn '((count++))' "$REPO_ROOT/plugins" --include='*.sh'; then
    fail "((count++)) idiom still present"
else
    pass "no ((count++)) occurrences remain"
fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
