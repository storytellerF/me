#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
REPOSITORY_DIR="$(dirname "$(dirname "$PLUGIN_DIR")")"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

pass_count=0

assert_exists() {
    local path="$1"
    local label="$2"
    if [[ -e "$path" ]]; then
        printf '  PASS: %s\n' "$label"
        ((pass_count += 1))
    else
        printf '  FAIL: %s\n' "$label" >&2
        exit 1
    fi
}

assert_contains() {
    local path="$1"
    local expected="$2"
    local label="$3"
    if grep -Fq "$expected" "$path"; then
        printf '  PASS: %s\n' "$label"
        ((pass_count += 1))
    else
        printf '  FAIL: %s\n' "$label" >&2
        exit 1
    fi
}

assert_not_contains() {
    local path="$1"
    local unexpected="$2"
    local label="$3"
    if grep -Fq "$unexpected" "$path"; then
        printf '  FAIL: %s\n' "$label" >&2
        exit 1
    fi
    printf '  PASS: %s\n' "$label"
    ((pass_count += 1))
}

OUTPUT_DIR="$WORK_DIR/codex-package"
"$REPOSITORY_DIR/scripts/build-codex-plugin-package.sh" "$PLUGIN_DIR" --output-dir "$OUTPUT_DIR"

assert_exists "$OUTPUT_DIR/.codex-plugin/plugin.json" "generated plugin manifest"
assert_exists "$OUTPUT_DIR/skills/test-report-sharing/SKILL.md" "generated test-report skill"
assert_exists "$OUTPUT_DIR/scripts/collect-test-results.sh" "generated runtime script"
assert_exists "$OUTPUT_DIR/templates/report-site.html" "generated template"
assert_contains "$OUTPUT_DIR/.codex-plugin/plugin.json" '"skills": "./skills/"' "manifest points to packaged skills"
assert_not_contains "$OUTPUT_DIR/skills/test-report-sharing/SKILL.md" 'context: fork' "test-report routing removed from package"
assert_not_contains "$OUTPUT_DIR/skills/test-report-sharing/SKILL.md" 'agent: test-report-operator' "test-report agent removed from package"
assert_contains "$PLUGIN_DIR/skills/test-report-sharing/SKILL.md" 'context: fork' "source routing preserved"
assert_contains "$PLUGIN_DIR/agents/test-report-operator.md" 'name: test-report-operator' "source agent metadata preserved"

printf '=== Results: %d passed, 0 failed ===\n' "$pass_count"
