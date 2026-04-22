# Dotfiles interactive shell config — loaded for every interactive shell
# Ensure env vars are set (non-login interactive shells skip .zprofile)
if [[ -z "${DOTFILES_HOME:-}" ]]; then
    export DOTFILES_HOME="$HOME/.dotfiles"
    export DOTFILES_BIN="$DOTFILES_HOME/bin"
    source "$DOTFILES_BIN/functions.sh"
fi

# Load interactive snippets from each active module
if [[ -n "${DOTFILES_PROFILE_NAME:-}" ]]; then
    modules_file="$DOTFILES_HOME/modules/modules.sh"
    if [[ -f "$modules_file" ]]; then
        while IFS= read -r module; do
            snippet="$DOTFILES_HOME/modules/$module/_zshrc.zsh"
            [[ -f "$snippet" ]] && source "$snippet"
        done < <(bash "$modules_file")
    fi
fi

# VS Code shell integration
if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    vscode_integration="$(code --locate-shell-integration-path zsh 2>/dev/null || true)"
    [[ -n "$vscode_integration" ]] && source "$vscode_integration"
fi

# Aliases
alias docker='podman'
