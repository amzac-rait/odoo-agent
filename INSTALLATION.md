# Installation Guide — Letzdoo Odoo Agent for Cursor

## Prerequisites

### All users
- [Cursor](https://cursor.com) IDE
- Git

### Doodba development (odoo-indexer, odoo-setup, odoo-test)
- Doodba-based Odoo deployment with `tasks.py`
- Docker 20.10+ and Docker Compose
- Python 3.10+
- [uv](https://docs.astral.sh/uv/) package manager (auto-installed by odoo-setup skill)

### Token optimization (OTK)
- Rust toolchain (`cargo`)
- `jq` (for the preToolUse hook)

### Live queries (odoo-query)
- Python 3 with stdlib only (no extra packages)

---

## Install Methods

### Global install

Skills are symlinked to `~/.cursor/skills/` and the OTK hook is merged into `~/.cursor/hooks.json`.

```bash
git clone https://github.com/amzac-rait/odoo-agent.git
cd odoo-agent
./scripts/install-cursor.sh --global
```

Best for: developers working on multiple Odoo projects who want patterns and query skills everywhere.

**Note:** The always-on Odoo workflow rule is **not** installed globally (too broad for non-Odoo repos). Use project install for that.

### Project install

Copies the full `.cursor/` tree into your Doodba/Odoo project — skills, rules, and hooks.

```bash
./scripts/install-cursor.sh --project /path/to/my-doodba-project
```

Best for: Doodba teams who want the complete stack (indexer, OTK hook, mandatory workflow rule).

### With dependencies

Build the Python indexer environment and Rust OTK binary during install:

```bash
./scripts/install-cursor.sh --global --with-deps
# or
./scripts/install-cursor.sh --project ~/my-odoo-project --with-deps
```

---

## Post-Install Setup

### 1. Doodba indexer (Doodba projects only)

Ask Cursor to run the **odoo-setup** skill, or manually:

```bash
cd ~/.cursor/skills/odoo-indexer   # or project/.cursor/skills/odoo-indexer
uv sync
export ODOO_PATH="/path/to/odoo/custom/src"
uv run scripts/update_index.py --full
uv run scripts/search.py "sale.order" --type model
```

### 2. OTK token optimization (optional)

Ask Cursor to run the **otk-setup** skill, or manually:

```bash
cd ~/.cursor/skills/otk-core
cargo install --path .
chmod +x ~/.cursor/hooks/otk-rewrite.sh   # global install
```

Verify in Cursor: Settings → Hooks, or run a shell command and check the Hooks output channel.

### 3. Verify skills loaded

Open Cursor Settings → Rules / Skills and confirm Letzdoo skills appear.

Run validation:

```bash
./scripts/validate-cursor.sh
```

---

## Troubleshooting

### Skills not appearing

- Restart Cursor after install
- Global: check `~/.cursor/skills/` contains symlinks
- Project: check `<project>/.cursor/skills/` exists

### Indexer not found / empty results

```bash
export ODOO_PATH="/path/to/odoo/custom/src"
cd .cursor/skills/odoo-indexer
uv sync
uv run scripts/update_index.py --clear --full
```

### OTK hook not firing

- Ensure `jq` is installed: `brew install jq` or `apt install jq`
- Check `.cursor/hooks.json` contains the `preToolUse` entry
- Make hook executable: `chmod +x .cursor/hooks/otk-rewrite.sh`
- Restart Cursor

### Docker not found

Install Docker: https://docs.docker.com/get-docker/

### Odoo query connection fails

- Verify URL, database name, login, and API key
- API keys: Odoo Settings → Users → API Keys
- Only read operations are supported (by design)

---

## Uninstall

```bash
./scripts/install-cursor.sh --uninstall --global
./scripts/install-cursor.sh --uninstall --project /path/to/project
```

This removes only files tracked in the Letzdoo manifest (`.cursor/letzdoo-manifest.json`).

---

## Migrating from Claude Code

This repository previously shipped as a Claude Code plugin marketplace. The equivalent mapping:

| Claude Code | Cursor |
|-------------|--------|
| `/plugin install` | `./scripts/install-cursor.sh` |
| `commands/*.md` | `.cursor/skills/<name>/SKILL.md` |
| `agents/*.md` | `.cursor/skills/<agent>/SKILL.md` |
| PreToolUse hook in `~/.claude/settings.json` | `.cursor/hooks.json` |
| `${CLAUDE_PLUGIN_ROOT}` | Relative paths within skill directories |
