---
name: otk-setup
description: Build and install OTK (Odoo Token Killer) Rust binary and register the Cursor preToolUse hook for token optimization. Use when user asks to setup otk, install token killer, or reports OTK not working.
disable-model-invocation: true
---

# OTK Setup

Set up OTK (Odoo Token Killer) for transparent token optimization in Cursor.

## Step 1: Check Prerequisites

```bash
which cargo && cargo --version
which jq && jq --version
```

If cargo is missing:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```

## Step 2: Build and Install OTK

```bash
cd ../otk-core && cargo install --path .
otk --version
```

## Step 3: Register Cursor Hook

For **project install**, ensure `.cursor/hooks.json` contains:

```json
{
  "version": 1,
  "hooks": {
    "preToolUse": [
      {
        "command": ".cursor/hooks/otk-rewrite.sh",
        "matcher": "Shell"
      }
    ]
  }
}
```

For **global install**, run `./scripts/install-cursor.sh --global` which merges this hook into `~/.cursor/hooks.json`.

Make the hook script executable:
```bash
chmod +x .cursor/hooks/otk-rewrite.sh
```

## Step 4: Report

```
OTK Setup Complete

  Binary:  otk (Rust, <10ms startup)
  Hook:    preToolUse registered (transparent command rewriting)
  Tee:     ~/.local/share/otk/tee/ (full output recovery)

Commands now automatically optimized:
  invoke test, docker logs, git status/diff, cat *.py, cat *.xml, grep, ls

Use the otk-gain skill to see token savings analytics.
```
