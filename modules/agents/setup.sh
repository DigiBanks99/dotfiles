#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_CONFIG="$SCRIPT_DIR/.config"

# Install GitHub Copilot CLI
log_info "Installing GitHub Copilot CLI..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask github-copilot-for-xcode 2>/dev/null || \
        brew install gh && gh extension install github/gh-copilot 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    gh extension install github/gh-copilot 2>/dev/null || true
elif command -v snap &>/dev/null; then
    sudo snap install gh && gh extension install github/gh-copilot 2>/dev/null || true
else
        log_warn "No supported package manager found for GitHub Copilot CLI. Install manually."
fi

# Symlink .agents
log_info "Linking ~/.agents..."
if [ -e "$HOME/.agents" ] || [ -L "$HOME/.agents" ]; then
    rm -rf "$HOME/.agents"
fi
ln -sf "$MODULE_CONFIG/.agents" "$HOME/.agents"

# Symlink ~/.claude/skills to the versioned skills directory
log_info "Linking ~/.claude/skills..."
CLAUDE_SKILLS="$HOME/.claude/skills"
SKILLS_TARGET="$MODULE_CONFIG/.agents/skills"
mkdir -p "$HOME/.claude"
if [ ! -d "$SKILLS_TARGET" ]; then
    log_warn "Skills directory not found ($SKILLS_TARGET). Skipping ~/.claude/skills link."
else
    if [ -e "$CLAUDE_SKILLS" ] && [ ! -L "$CLAUDE_SKILLS" ]; then
        # A real directory: move it aside rather than delete it, then carry over app-managed state
        SKILLS_BACKUP="$CLAUDE_SKILLS.bak-$(date +%Y%m%d%H%M%S)"
        mv "$CLAUDE_SKILLS" "$SKILLS_BACKUP"
        for keep in synced .trash; do
            if [ -e "$SKILLS_BACKUP/$keep" ]; then
                mv "$SKILLS_BACKUP/$keep" "$SKILLS_TARGET/$keep"
            fi
        done
        log_info "Previous ~/.claude/skills kept at $SKILLS_BACKUP"
    fi
    ln -sfn "$SKILLS_TARGET" "$CLAUDE_SKILLS"
fi

# Symlink .copilot
log_info "Linking ~/.copilot..."
if [ -e "$HOME/.copilot" ] || [ -L "$HOME/.copilot" ]; then
    rm -rf "$HOME/.copilot"
fi
ln -sf "$MODULE_CONFIG/.copilot" "$HOME/.copilot"

# Generate config.json from template
log_info "Generating ~/.copilot/config.json from template..."
TEMPLATE="$MODULE_CONFIG/config.template.json"
CONFIG="$MODULE_CONFIG/.copilot/config.json"
sed "s|{{USERPROFILE}}|$HOME|g" "$TEMPLATE" > "$CONFIG"

log_info "Done. ~/.agents and ~/.copilot are ready."
