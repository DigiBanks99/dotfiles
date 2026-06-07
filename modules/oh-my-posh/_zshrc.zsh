THEME_FILE="$DOTFILES_HOME/modules/oh-my-posh/.config/omp.json"
log_debug "Initializing Oh My Posh with theme file: $THEME_FILE"

eval "$(oh-my-posh init zsh --config "$THEME_FILE")"
