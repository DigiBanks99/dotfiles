export DOTFILES_HOME="$HOME/.dotfiles"
export DOTFILES_BIN="$DOTFILES_HOME/bin"

# Load helper functions early so logging helpers exist
source "$DOTFILES_BIN/_bootstrap.zsh"

export PATH="$DOTFILES_BIN:$PATH"

autoload -Uz compinit && compinit

# Aliases
log_debug "Setting up aliases..."
alias docker='podman'
alias ls='ls -al --color=always'
alias dir='ls'
alias chx="find . --name '*.sh' -exec chmod +x {} \;"
alias chxz="find . --name '*.zsh' -exec chmod +x {} \;"
alias reload="source ~/.zshrc"

# Load env snippets from each active module
for module in $DOTFILES_MODULES; do
    EXEC_FILE_NAME="$DOTFILES_HOME/modules/$module/_zshrc.zsh"
    log_debug "Reading $EXEC_FILE_NAME..."
    [[ -e "$EXEC_FILE_NAME" ]] && source "$EXEC_FILE_NAME"
done

export BROWSER=/usr/bin/wslview

# VS Code shell integration
if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    log_info "Loading VS Code shell integration..."
    vscode_integration="$(code --locate-shell-integration-path zsh 2>/dev/null || true)"
    [[ -n "$vscode_integration" ]] && source "$vscode_integration"
fi

export EDITOR=vim

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"
