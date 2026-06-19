#!/bin/bash
# OTK preToolUse hook - transparent command rewriting for Cursor
# Intercepts Shell tool calls and rewrites them to use otk filters.

set -euo pipefail

if ! command -v jq &>/dev/null; then
    exit 0
fi

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // .toolName // empty')
if [ "$TOOL" != "Shell" ] && [ "$TOOL" != "Bash" ]; then
    exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // .toolInput.command // .command // empty')
if [ -z "$CMD" ]; then
    exit 0
fi

if echo "$CMD" | grep -q '<<'; then
    exit 0
fi

FIRST_CMD=$(echo "$CMD" | sed 's/[|&;].*//' | sed 's/^\s*//' | sed 's/\s*$//')

ENV_PREFIX=$(echo "$FIRST_CMD" | grep -oE '^([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)+' || echo "")
if [ -n "$ENV_PREFIX" ]; then
    FIRST_CMD="${FIRST_CMD#$ENV_PREFIX}"
fi

OTK_CMD=""
if command -v otk &>/dev/null; then
    OTK_CMD="otk"
elif [ -x "$HOME/.cargo/bin/otk" ]; then
    OTK_CMD="$HOME/.cargo/bin/otk"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills/otk-core" 2>/dev/null && pwd)"
    if [ -n "$SCRIPT_DIR" ] && [ -x "$SCRIPT_DIR/target/release/otk" ]; then
        OTK_CMD="$SCRIPT_DIR/target/release/otk"
    else
        exit 0
    fi
fi

REWRITTEN=""

case "$FIRST_CMD" in
    "invoke test"*|pytest*|"python -m pytest"*|*"odoo-bin --test"*|*"odoo-bin -t"*)
        REWRITTEN="${ENV_PREFIX}${OTK_CMD} ${FIRST_CMD}"
        ;;
    "docker compose logs"*|"docker-compose logs"*| "docker logs"*| "docker ps"*| "docker images"*)
        REWRITTEN="${ENV_PREFIX}${OTK_CMD} ${FIRST_CMD}"
        ;;
    "git status"*| "git diff"*| "git log"*| "git add"*| "git commit"*| "git push"*| "git pull"*| "git fetch"*| "git stash"*| "git checkout"*)
        REWRITTEN="${ENV_PREFIX}${OTK_CMD} ${FIRST_CMD}"
        ;;
    "cat "*.py|"cat "*.xml|"cat "*.csv)
        FILE=$(echo "$FIRST_CMD" | awk '{print $NF}')
        REWRITTEN="${ENV_PREFIX}${OTK_CMD} read ${FILE}"
        ;;
    "grep "*|"rg "*|"ls "*|"tree "*|"find "*|"pip list"*| "pip install"*| "pip freeze"*| "psql "*)
        REWRITTEN="${ENV_PREFIX}${OTK_CMD} ${FIRST_CMD}"
        ;;
esac

if [ -z "$REWRITTEN" ]; then
    exit 0
fi

REST=$(echo "$CMD" | sed "s|^[^|&;]*||")
FINAL_CMD="${REWRITTEN}${REST}"

cat <<HOOK_JSON
{
  "permission": "allow",
  "updated_input": {
    "command": $(echo "$FINAL_CMD" | jq -Rs .)
  }
}
HOOK_JSON
