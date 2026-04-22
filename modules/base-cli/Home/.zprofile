# Dotfiles environment — loaded at login shell start
export DOTFILES_HOME="$HOME/.dotfiles"
export DOTFILES_BIN="$DOTFILES_HOME/bin"

# PATH additions: dotfiles bin, pnpm local bin, Rust
export PNPM_HOME="$HOME/.local/bin"
export PATH="$DOTFILES_BIN:$PNPM_HOME:$HOME/.cargo/bin:$PATH"

source "$DOTFILES_BIN/functions.sh"

# Load env snippets from each active module
if [[ -n "${DOTFILES_PROFILE_NAME:-}" ]]; then
    modules_file="$DOTFILES_HOME/modules/modules.sh"
    if [[ -f "$modules_file" ]]; then
        while IFS= read -r module; do
            snippet="$DOTFILES_HOME/modules/$module/_zprofile.zsh"
            [[ -f "$snippet" ]] && source "$snippet"
        done < <(bash "$modules_file")
    fi
fi
