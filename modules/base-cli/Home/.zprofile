# Dotfiles environment — loaded at login shell start
DOTFILES_HOME="$HOME/.dotfiles"
DOTFILES_BIN="$DOTFILES_HOME/bin"
source "$DOTFILES_BIN/_bootstrap.zsh"

# PATH additions: dotfiles bin, pnpm local bin, Rust
export PNPM_HOME="$HOME/.local/bin"
export PATH="$DOTFILES_BIN:$PNPM_HOME:$HOME/.cargo/bin:$PATH"

export BROWSER=/usr/bin/wslview

# Load env snippets from each active module
for module in $DOTFILES_MODULES; do
    log_debug "Processing module '$module' for .zprofile..."
    EXEC_FILE_NAME="$DOTFILES_HOME/modules/$module/_zprofile.zsh"
    if [[ -e "$EXEC_FILE_NAME" ]]; then
        log_debug "Reading $EXEC_FILE_NAME..."
        source "$EXEC_FILE_NAME"
    fi
done

log_debug "Finished loading .zprofile"
