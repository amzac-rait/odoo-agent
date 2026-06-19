#!/usr/bin/env bash
# Install Letzdoo Odoo Agent skills for Cursor
# Usage:
#   ./scripts/install-cursor.sh --global
#   ./scripts/install-cursor.sh --project /path/to/odoo-project
#   ./scripts/install-cursor.sh --uninstall --global
#   ./scripts/install-cursor.sh --uninstall --project /path/to/odoo-project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_CURSOR="$REPO_ROOT/.cursor"
MANIFEST_NAME="letzdoo-manifest.json"

GLOBAL_SKILLS="$HOME/.cursor/skills"
GLOBAL_HOOKS="$HOME/.cursor/hooks.json"
GLOBAL_HOOKS_DIR="$HOME/.cursor/hooks"

usage() {
    cat <<EOF
Usage: $0 [--global | --project PATH] [--uninstall] [--with-deps]

  --global          Install skills and OTK hook to ~/.cursor/
  --project PATH    Copy full .cursor/ tree into a project
  --uninstall       Remove Letzdoo-managed files (uses manifest)
  --with-deps       Run uv sync (indexer) and cargo install (otk) if tools exist

Examples:
  $0 --global
  $0 --project ~/my-doodba-project
  $0 --uninstall --global
EOF
    exit 1
}

write_manifest() {
    local manifest_path="$1"
    shift
    mkdir -p "$(dirname "$manifest_path")"
    printf '%s\n' "$@" | jq -R . | jq -s '{version: 1, files: .}' > "$manifest_path"
}

install_global() {
    mkdir -p "$GLOBAL_SKILLS" "$GLOBAL_HOOKS_DIR"
    local manifest_entries=()

    for skill_dir in "$SOURCE_CURSOR/skills"/*; do
        [ -d "$skill_dir" ] || continue
        local name
        name="$(basename "$skill_dir")"
        local target="$GLOBAL_SKILLS/$name"
        rm -rf "$target"
        ln -sf "$skill_dir" "$target"
        manifest_entries+=("$target")
        echo "Linked skill: $name -> $skill_dir"
    done

    # OTK hook script
    cp "$SOURCE_CURSOR/hooks/otk-rewrite.sh" "$GLOBAL_HOOKS_DIR/otk-rewrite.sh"
    chmod +x "$GLOBAL_HOOKS_DIR/otk-rewrite.sh"
    manifest_entries+=("$GLOBAL_HOOKS_DIR/otk-rewrite.sh")

    # Merge hooks.json
    local otk_hook
    otk_hook='{"command": "./hooks/otk-rewrite.sh", "matcher": "Shell"}'
    if [ -f "$GLOBAL_HOOKS" ]; then
        cp "$GLOBAL_HOOKS" "$GLOBAL_HOOKS.bak"
        jq --argjson entry "$otk_hook" '
            .version //= 1 |
            .hooks.preToolUse //= [] |
            .hooks.preToolUse |= map(select(.command != "./hooks/otk-rewrite.sh")) |
            .hooks.preToolUse += [$entry]
        ' "$GLOBAL_HOOKS" > "$GLOBAL_HOOKS.tmp" && mv "$GLOBAL_HOOKS.tmp" "$GLOBAL_HOOKS"
    else
        jq -n --argjson entry "$otk_hook" '{
            version: 1,
            hooks: { preToolUse: [$entry] }
        }' > "$GLOBAL_HOOKS"
    fi
    manifest_entries+=("$GLOBAL_HOOKS")

    write_manifest "$HOME/.cursor/$MANIFEST_NAME" "${manifest_entries[@]}"
    echo "Global install complete. Skills in $GLOBAL_SKILLS"
    echo "Note: odoo-development rule not installed globally (use --project for full stack)."
}

install_project() {
    local project_path="$1"
    local target_cursor="$project_path/.cursor"
    mkdir -p "$project_path"

    if [ -d "$target_cursor" ]; then
        cp -R "$target_cursor" "${target_cursor}.bak.$(date +%s)"
        echo "Backed up existing .cursor/ directory"
    fi

    cp -R "$SOURCE_CURSOR" "$target_cursor"
    chmod +x "$target_cursor/hooks/otk-rewrite.sh"

    local manifest_entries=()
    while IFS= read -r -d '' f; do
        manifest_entries+=("$f")
    done < <(find "$target_cursor" -type f -print0)

    write_manifest "$target_cursor/$MANIFEST_NAME" "${manifest_entries[@]}"
    echo "Project install complete: $target_cursor"
}

uninstall() {
    local manifest_path="$1"
    if [ ! -f "$manifest_path" ]; then
        echo "No manifest found at $manifest_path"
        exit 1
    fi

    jq -r '.files[]' "$manifest_path" | while read -r f; do
        if [ -L "$f" ]; then
            rm -f "$f"
            echo "Removed symlink: $f"
        elif [ "$f" = "$GLOBAL_HOOKS" ]; then
            if [ -f "$GLOBAL_HOOKS.bak" ]; then
                mv "$GLOBAL_HOOKS.bak" "$GLOBAL_HOOKS"
                echo "Restored hooks.json from backup"
            else
                jq '.hooks.preToolUse |= map(select(.command != "./hooks/otk-rewrite.sh"))' "$GLOBAL_HOOKS" > "$GLOBAL_HOOKS.tmp" 2>/dev/null && mv "$GLOBAL_HOOKS.tmp" "$GLOBAL_HOOKS" || true
            fi
        elif [ -f "$f" ]; then
            rm -f "$f"
            echo "Removed: $f"
        fi
    done

    rm -f "$manifest_path"
    echo "Uninstall complete."
}

install_deps() {
    if command -v uv &>/dev/null && [ -d "$SOURCE_CURSOR/skills/odoo-indexer" ]; then
        echo "Running uv sync for odoo-indexer..."
        (cd "$SOURCE_CURSOR/skills/odoo-indexer" && uv sync)
    fi
    if command -v cargo &>/dev/null && [ -d "$SOURCE_CURSOR/skills/otk-core" ]; then
        echo "Building otk..."
        (cd "$SOURCE_CURSOR/skills/otk-core" && cargo install --path . 2>/dev/null || cargo build --release)
    fi
}

# Parse args
MODE=""
PROJECT_PATH=""
UNINSTALL=false
WITH_DEPS=false

while [ $# -gt 0 ]; do
    case "$1" in
        --global) MODE="global"; shift ;;
        --project) MODE="project"; PROJECT_PATH="$2"; shift 2 ;;
        --uninstall) UNINSTALL=true; shift ;;
        --with-deps) WITH_DEPS=true; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

[ -n "$MODE" ] || usage

if [ "$UNINSTALL" = true ]; then
    if [ "$MODE" = "global" ]; then
        uninstall "$HOME/.cursor/$MANIFEST_NAME"
    else
        uninstall "$PROJECT_PATH/.cursor/$MANIFEST_NAME"
    fi
    exit 0
fi

if [ "$MODE" = "global" ]; then
    install_global
elif [ "$MODE" = "project" ]; then
    [ -n "$PROJECT_PATH" ] || usage
    install_project "$(cd "$PROJECT_PATH" && pwd)"
fi

if [ "$WITH_DEPS" = true ]; then
    install_deps
fi
