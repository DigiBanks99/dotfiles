#!/user/bin/env zsh

brew_bundle() {
    local path_to_bundle=$1
    logging_debug "Bundle $DOTFILES_CYAN}$path_to_bundle${DOTFILES_RESET}"
    brew bundle --file="$path_to_bundle"
}

module_brew_bundle() {
    local module="$1"
    local bundle_file_name="$DOTFILES_HOME/modules/$module/Brewfile"
    brew_bundle "$bundle_file_name"
}

# if DOTFILES_LOG_LEVEL is not yet set, default to INFO
if [[ -z "${DOTFILES_LOG_LEVEL:-}" ]]; then
    export DOTFILES_LOG_LEVEL="INFO"
fi

get_log_level() {
    case "${DOTFILES_LOG_LEVEL:-}" in
        1|ERROR) echo 1 ;;
        2|WARN)  echo 2 ;;
        3|INFO)  echo 3 ;;
        4|DEBUG) echo 4 ;;
        *)       echo 2 ;;
    esac
}

log_error() {
    [[ "$(get_log_level)" -ge 1 ]] && echo "[${DOTFILES_RED}ERR${DOTFILES_RESET}]: $1" >&2
}

log_warn() {
    [[ "$(get_log_level)" -ge 2 ]] && echo "[${DOTFILES_YELLOW}WARN${DOTFILES_RESET}]: $1" >&2
}

log_info() {
    [[ "$(get_log_level)" -ge 3 ]] && echo "[${DOTFILES_CYAN}INF${DOTFILES_RESET}]: $1" >&2
}

log_debug() {
    [[ "$(get_log_level)" -ge 4 ]] && echo "[${DOTFILES_GREEN}DBG${DOTFILES_RESET}]: $1" >&2
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        log_error "Command not found: $1"
        return 1
    fi
    return 0
}

resolve_profile() {
    local cache_file="$HOME/.dotfiles-profile"
    if [[ -f "$cache_file" ]]; then
        local cached
        cached="$(cat "$cache_file" | tr -d '[:space:]')"
        if [[ -n "$cached" ]]; then
            log_debug "Using cached profile: $cached"
            export DOTFILES_PROFILE_NAME="$cached"
            return
        fi
    fi
    printf "What profile are you configuring? " >&2
    read -r profile
    echo "$profile" > "$cache_file"
    export DOTFILES_PROFILE_NAME="$profile"
}

resolve_distro() {
    local cache_file="$HOME/.dotfiles-distro"
    if [[ -f "$cache_file" ]]; then
        local cached
        cached="$(cat "$cache_file" | tr -d '[:space:]')"
        if [[ -n "$cached" ]]; then
            log_info "Using cached distro: $cached"
            export DOTFILES_DISTRO="$cached"
            return
        fi
    fi

    local detected=""
    if [[ -f /etc/os-release ]]; then
        detected="$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')"
    fi

    local known_distros=("ubuntu" "fedora" "nix")
    local distro=""

    for d in "${known_distros[@]}"; do
        if [[ "$detected" == "$d" ]]; then
            distro="$detected"
            break
        fi
    done

    if [[ -z "$distro" ]]; then
        if [[ -n "$detected" ]]; then
            log_warn "Unrecognised distro: '$detected'."
        fi
        printf "What Linux distro are you on (ubuntu / fedora / nix)? " >&2
        read -r distro
        distro="$(echo "$distro" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
    fi

    echo "$distro" > "$cache_file"
    export DOTFILES_DISTRO="$distro"
    log_debug "Distro resolved: $DOTFILES_DISTRO"
}

get_package_manager() {
    case "${DOTFILES_DISTRO:-}" in
        ubuntu)  echo "apt-get" ;;
        fedora)  echo "dnf" ;;
        nix)     echo "nix-env" ;;
        *)
            log_error "Unsupported or unset distro: '${DOTFILES_DISTRO:-}'. Run 'resolve_distro' first."
            return 1
            ;;
    esac
}