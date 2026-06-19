#!/usr/bin/env bash
# Validate Letzdoo Odoo Agent Cursor package structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CURSOR_DIR="$REPO_ROOT/.cursor"
ERRORS=0

error() {
    echo "ERROR: $1" >&2
    ERRORS=$((ERRORS + 1))
}

check_skill() {
    local skill_path="$1"
    local skill_md="$skill_path/SKILL.md"
    if [ ! -f "$skill_md" ]; then
        error "Missing SKILL.md in $skill_path"
        return
    fi
    if ! head -1 "$skill_md" | grep -q '^---'; then
        error "No YAML frontmatter in $skill_md"
    fi
    if ! grep -q '^name:' "$skill_md"; then
        error "Missing name in frontmatter: $skill_md"
    fi
    if ! grep -q '^description:' "$skill_md"; then
        error "Missing description in frontmatter: $skill_md"
    fi
}

echo "Validating Cursor package at $CURSOR_DIR..."

# Required directories
for dir in skills rules hooks; do
    [ -d "$CURSOR_DIR/$dir" ] || error "Missing directory: .cursor/$dir"
done

# hooks.json at .cursor root
[ -f "$CURSOR_DIR/hooks.json" ] || error "Missing .cursor/hooks.json"
[ -x "$CURSOR_DIR/hooks/otk-rewrite.sh" ] || {
    chmod +x "$CURSOR_DIR/hooks/otk-rewrite.sh" 2>/dev/null || error "otk-rewrite.sh not executable"
}

# Rule
[ -f "$CURSOR_DIR/rules/odoo-development.mdc" ] || error "Missing odoo-development.mdc rule"

# Skills (excluding otk-core which is a library, not a user-facing skill)
EXPECTED_SKILLS=(
    odoo-development odoo-context-gatherer odoo-code-reviewer
    odoo-upgrade-analyzer odoo-skill-finder odoo-module odoo-owl
    odoo-review odoo-security odoo-gen-test odoo-upgrade
    odoo-indexer odoo-setup odoo-test odoo-query otk otk-setup otk-gain
)

for skill in "${EXPECTED_SKILLS[@]}"; do
    check_skill "$CURSOR_DIR/skills/$skill"
done

# Reference patterns count
REF_COUNT=$(find "$CURSOR_DIR/skills/odoo-development/reference" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$REF_COUNT" -lt 100 ]; then
    error "Expected 100+ reference patterns, found $REF_COUNT"
else
    echo "OK: $REF_COUNT reference pattern files"
fi

# Executable scripts
[ -f "$CURSOR_DIR/skills/odoo-query/scripts/odoo_xmlrpc.py" ] || error "Missing odoo_xmlrpc.py"
[ -f "$CURSOR_DIR/skills/odoo-indexer/pyproject.toml" ] || error "Missing odoo-indexer pyproject.toml"
[ -f "$CURSOR_DIR/skills/otk-core/Cargo.toml" ] || error "Missing otk-core Cargo.toml"

# No stale Claude references in skills
if grep -r 'CLAUDE_PLUGIN_ROOT' "$CURSOR_DIR/skills" --include='*.md' -q 2>/dev/null; then
    error "Found stale CLAUDE_PLUGIN_ROOT references"
fi

# Install script
[ -x "$REPO_ROOT/scripts/install-cursor.sh" ] || {
    chmod +x "$REPO_ROOT/scripts/install-cursor.sh" 2>/dev/null || error "install-cursor.sh not executable"
}

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "Validation passed."
    exit 0
else
    echo "Validation failed with $ERRORS error(s)."
    exit 1
fi
