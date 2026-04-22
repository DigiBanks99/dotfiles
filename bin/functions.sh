#!/usr/bin/env bash

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
        *)       echo 3 ;;
    esac
}

log_error() {
    [[ "$(get_log_level)" -ge 1 ]] && echo "[ERR]: $1" >&2
}

log_warn() {
    [[ "$(get_log_level)" -ge 2 ]] && echo "[WARN]: $1" >&2
}

log_info() {
    [[ "$(get_log_level)" -ge 3 ]] && echo "[INF]: $1" >&2
}

log_debug() {
    [[ "$(get_log_level)" -ge 4 ]] && echo "[DBG]: $1" >&2
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        log_error "Command not found: $1"
        return 1
    fi
    return 0
}

get_os() {
    log_info "Detecting operating system..."
    log_debug "OSTYPE: $OSTYPE"
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
        read -rp "What Linux distro are you on (ubuntu / fedora / nix)? " distro
        distro="$(echo "$distro" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
    fi

    echo "$distro" > "$cache_file"
    export DOTFILES_DISTRO="$distro"
    log_info "Distro resolved: $DOTFILES_DISTRO"
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
