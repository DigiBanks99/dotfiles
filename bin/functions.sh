#!/usr/bin/env bash

get_log_level() {
    case "${DOTFILES_LOG_LEVEL:-}" in
        1|ERROR) echo 1 ;;
        2|WARN)  echo 2 ;;
        3|INFO)  echo 3 ;;
        4|DEBUG) echo 4 ;;
        *)       echo 3 ;;
    esac
}

log_error() {
    [[ "$(get_log_level)" -ge 1 ]] && echo "[ERR]: $1" >&2
}

log_warn() {
    [[ "$(get_log_level)" -ge 2 ]] && echo "[WARN]: $1"
}

log_info() {
    [[ "$(get_log_level)" -ge 3 ]] && echo "[INF]: $1"
}

log_debug() {
    [[ "$(get_log_level)" -ge 4 ]] && echo "[DBG]: $1"
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        log_error "Command not found: $1"
        return 1
    fi
    return 0
}

get_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Darwin"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "Nix"
    fi
}

resolve_profile() {
    local cache_file="$HOME/.dotfiles-profile"
    if [[ -f "$cache_file" ]]; then
        local cached
        cached="$(cat "$cache_file" | tr -d '[:space:]')"
        if [[ -n "$cached" ]]; then
            log_info "Using cached profile: $cached"
            export DOTFILES_PROFILE_NAME="$cached"
            return
        fi
    fi
    read -rp "What profile are you configuring? " profile
    echo "$profile" > "$cache_file"
    export DOTFILES_PROFILE_NAME="$profile"
}
