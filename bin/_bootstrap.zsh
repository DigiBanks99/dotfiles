export DOTFILES_HOME=~/.dotfiles
export DOTFILES_BIN="$DOTFILES_HOME/bin"
export XDG_CONFIG_HOME="$HOME/.config"

export DOTFILES_GREEN="\033[32m"
export DOTFILES_RED="\033[31m"
export DOTFILES_CYAN="\033[36m"
export DOTFILES_YELLOW="\033[33m"
export DOTFILES_RESET="\033[0m"

export DOTFILES_LOG_LEVEL="DEBUG"

source "$DOTFILES_BIN/_functions.zsh"

log_debug "Profile: ${DOTFILES_PROFILE_NAME:-}"
if [[ -z "${DOTFILES_PROFILE_NAME:-}" ]]; then
    log_debug "Profile not set. Resolving..."
    resolve_profile
fi

log_info "Loading $DOTFILES_PROFILE_NAME profile modules..."
source "$DOTFILES_HOME/modules/$DOTFILES_PROFILE_NAME.zsh"
