---
name: odoo-setup
description: Validate Doodba environment, install dependencies, and build the Odoo code indexer. Use when user asks to setup, install, configure Odoo dev environment, or reports indexer not working.
disable-model-invocation: true
---

# Odoo Setup

Perform complete Doodba environment validation and indexer setup. Execute all steps autonomously and return ONLY a final status report.

## Setup Steps

### Step 1: Check Docker

```bash
docker --version
```

**Expected**: Docker version 20.10+. If missing, return error report and stop.

### Step 2: Check Docker Compose

```bash
docker compose version
```

**Expected**: Docker Compose v2+.

### Step 3: Check Python

```bash
python3 --version
```

**Expected**: Python 3.10+. If version < 3.10, return error report and stop.

### Step 4: Check/Install uv

```bash
uv --version
```

**If missing**:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"
uv --version
```

### Step 5: Detect Odoo Path

```bash
if [ -n "$ODOO_PATH" ]; then
    echo "Using ODOO_PATH=$ODOO_PATH"
elif [ -d "./odoo/custom/src/odoo" ]; then
    export ODOO_PATH="$(pwd)/odoo/custom/src"
elif [ -d "$HOME/odoo/custom/src/odoo" ]; then
    export ODOO_PATH="$HOME/odoo/custom/src"
fi
```

If not found, ask the user for the path and set `ODOO_PATH`.

### Step 6: Build Indexer Database

From the odoo-indexer skill directory (sibling: `../odoo-indexer` when skills are installed globally):

```bash
cd ../odoo-indexer
uv sync
uv run scripts/update_index.py --full
```

### Step 7: Validate Indexer

```bash
uv run scripts/search.py "sale.order" --type model --limit 1
```

**Expected**: Results returned with query time <100ms.

## Final Report Format

```
Setup Complete!

Configuration:
  - Docker:         {version}
  - Docker Compose: {version}
  - Python:         {version}
  - uv:             {version}
  - Odoo path:      {path}
  - Indexer DB:     {size} ({modules} modules, {models} models)

Performance:
  - Search speed: {query_time}ms

Ready to use! Ask about Odoo code:
  "What is sale.order?"
  "What fields does res.partner have?"
```

## Troubleshooting

### Docker not found
Install Docker: https://docs.docker.com/get-docker/

### Python version too old
Install Python 3.10+ via pyenv or your system package manager.

### Odoo path not detected
```bash
export ODOO_PATH="/path/to/odoo/custom/src"
```

### Indexer build fails
```bash
cd ../odoo-indexer
uv sync
uv run scripts/update_index.py --clear --full
```
