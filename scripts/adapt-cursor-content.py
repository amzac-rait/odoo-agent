#!/usr/bin/env python3
"""One-time migration helper: adapt skill content for Cursor."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / ".cursor"

REPLACEMENTS = [
    (r"\$\{CLAUDE_PLUGIN_ROOT\}/scripts/odoo_xmlrpc\.py", "scripts/odoo_xmlrpc.py"),
    (r"\$\{CLAUDE_PLUGIN_ROOT\}/skills/otk-core", "../otk-core"),
    (r"\$\{CLAUDE_PLUGIN_ROOT\}/skills/odoo-indexer", "../odoo-indexer"),
    (r"\$\{CLAUDE_PLUGIN_ROOT\}/skills/", "../odoo-development/reference/"),
    (r"odoo-development/skills/", "../odoo-development/reference/"),
    (r"odoo-doodba-dev/skills/odoo-indexer", "../odoo-indexer"),
    (r"cd skills/odoo-indexer", "cd ../odoo-indexer"),
    (r"skills/odoo-indexer/", "../odoo-indexer/"),
    (r'subagent_type="odoo-development:odoo-context-gatherer"', 'subagent_type="generalPurpose"'),
    (r'subagent_type="odoo-development:odoo-code-reviewer"', 'subagent_type="generalPurpose"'),
    (r"subagent_type: odoo-doodba-dev:odoo-setup", "subagent_type: generalPurpose"),
    (r"`odoo-development:odoo-context-gatherer` agent", "odoo-context-gatherer skill via Task tool"),
    (r"`odoo-development:odoo-code-reviewer` agent", "odoo-code-reviewer skill via Task tool"),
    (r"Invoke `odoo-development:odoo-context-gatherer` agent", "Invoke odoo-context-gatherer skill via Task tool"),
    (r"Invoke `odoo-development:odoo-code-reviewer` agent", "Invoke odoo-code-reviewer skill via Task tool"),
    (r"Claude MUST", "You MUST"),
    (r"Claude Code", "Cursor"),
    (r"uv run otk ", "otk "),
    (r"PLUGIN_ROOT/hooks/otk-rewrite\.sh", ".cursor/hooks/otk-rewrite.sh"),
    (r"Replace `PLUGIN_ROOT` with the actual `\$\{CLAUDE_PLUGIN_ROOT\}` path\.", ""),
]

FRONTMATTER_STRIP = re.compile(
    r"^(allowed-tools:|tools:\n(?:  - .+\n)+|model: .+\n|color: .+\n)",
    re.MULTILINE,
)


def adapt_file(path: Path) -> bool:
    text = path.read_text()
    original = text
    for pattern, repl in REPLACEMENTS:
        text = re.sub(pattern, repl, text)
    if path.suffix == ".md" and "SKILL.md" in path.name or path.parent.name in {
        "reference",
        "odoo-query",
    }:
        # Fix skills/ -> reference/ in odoo-development index and reference files
        if "odoo-development" in str(path):
            text = text.replace("`skills/", "`reference/")
            text = text.replace("→ Read: skills/", "→ Read: reference/")
            text = text.replace("- `skills/", "- `reference/")
    text = FRONTMATTER_STRIP.sub("", text)
    if text != original:
        path.write_text(text)
        return True
    return False


def main() -> None:
    changed = 0
    for path in ROOT.rglob("*"):
        if path.suffix in {".md", ".sh"} and path.is_file():
            if adapt_file(path):
                changed += 1
                print(f"updated: {path.relative_to(ROOT.parent)}")
    print(f"Done. {changed} files updated.")


if __name__ == "__main__":
    main()
