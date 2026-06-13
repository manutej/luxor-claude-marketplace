#!/bin/bash
# Behavioral regression test for C07: ((count++)) under `set -e` aborted
# every installer after the first skill (post-increment of 0 returns a
# 0-valued arithmetic expression -> exit status 1 -> set -e kills the script).
# The same idiom ((skill_count++)) in uninstall.sh aborted the uninstaller
# after removing skill #1, leaving the rest stale.
#
# Proves four things:
#   1. The patched install.sh scripts install ALL declared skills and exit 0.
#   2. The pre-fix install.sh (from main) really did abort after skill #1,
#      so this test fails on the buggy code (it is not a tautology).
#   3. The patched uninstall.sh scripts remove ALL declared skills and exit 0,
#      and the pre-fix uninstall.sh (from main) aborts after removing 1 skill.
#   4. No ((var++)) / ((var--)) idiom survives anywhere in plugins/*.sh.
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

run_uninstaller() {
    # $1 = plugin dir, $2 = uninstall script path; pre-populates a fake HOME
    # with every skill the script declares, pipes the "y" confirmation, and
    # echoes "exit_code skills_left" on stdout.
    local plugin_dir="$1" script="$2"
    local fake_home skill
    fake_home="$(mktemp -d)"
    mkdir -p "$fake_home/.claude/skills"
    while IFS= read -r skill; do
        mkdir -p "$fake_home/.claude/skills/$skill"
    done < <(sed -n '/^SKILLS=(/,/^)/p' "$script" | grep -o '"[^"]*"' | tr -d '"')
    local seeded
    seeded=$(find "$fake_home/.claude/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)
    ( cd "$plugin_dir" && HOME="$fake_home" bash "$script" >/dev/null 2>&1 <<< "y" )
    local rc=$?
    local left
    left=$(find "$fake_home/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    rm -rf "$fake_home"
    echo "$rc $seeded $left"
}

echo ""
echo "=== 3. Negative control: pre-fix uninstaller (from main) must abort after removing skill #1 ==="
UNINST_PLUGIN="$REPO_ROOT/plugins/luxor-frontend-essentials"
BUGGY_UNINST="$(mktemp /tmp/buggy-uninstall-XXXXXX.sh)"
if git -C "$REPO_ROOT" show main:plugins/luxor-frontend-essentials/uninstall.sh > "$BUGGY_UNINST" 2>/dev/null; then
    if grep -q '((skill_count++))' "$BUGGY_UNINST"; then
        read -r rc seeded left <<< "$(run_uninstaller "$UNINST_PLUGIN" "$BUGGY_UNINST")"
        if [ "$rc" -ne 0 ] && [ "$left" -eq $((seeded - 1)) ]; then
            pass "buggy main uninstaller aborted after 1 removal (exit=$rc, $left/$seeded left stale) — test detects the bug"
        else
            fail "buggy main uninstaller did NOT reproduce the abort (exit=$rc, seeded=$seeded, left=$left)"
        fi
    else
        fail "main copy of uninstall.sh no longer contains ((skill_count++)); negative control invalid"
    fi
else
    fail "could not extract pre-fix uninstall.sh from main"
fi
rm -f "$BUGGY_UNINST"

echo ""
echo "=== 4. Patched uninstallers: every declared skill removed, exit 0 ==="
UNINST_TESTED=0
for script in "$REPO_ROOT"/plugins/*/uninstall.sh; do
    [ -f "$script" ] || continue
    plugin_dir="$(dirname "$script")"
    plugin="$(basename "$plugin_dir")"
    grep -q '^SKILLS=(' "$script" || continue
    UNINST_TESTED=$((UNINST_TESTED+1))
    read -r rc seeded left <<< "$(run_uninstaller "$plugin_dir" "$script")"
    if [ "$seeded" -lt 2 ]; then
        fail "$plugin: only $seeded declared skills seeded — cannot prove multi-skill progress"
    elif [ "$rc" -eq 0 ] && [ "$left" -eq 0 ]; then
        pass "$plugin: exit=0, removed all $seeded skills, 0 left stale"
    else
        fail "$plugin: exit=$rc, removed $((seeded - left))/$seeded skills, $left left stale"
    fi
done
[ "$UNINST_TESTED" -ge 1 ] || fail "expected to exercise >=1 uninstaller, ran $UNINST_TESTED"

echo ""
echo "=== 5. Regression guard: no ((var++)) / ((var--)) anywhere in plugin scripts ==="
if grep -rnE '\(\([A-Za-z_][A-Za-z0-9_]*(\+\+|--)\)\)' "$REPO_ROOT/plugins" --include='*.sh'; then
    fail "((var++)) / ((var--)) idiom still present in plugins/*.sh"
else
    pass "no ((var++)) / ((var--)) occurrences remain in plugins/*.sh"
fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
