# Prompt
# Simple prompt: user@host /path > with colored directory
PROMPT='%n@%m %F{cyan}%~%f > '

# fzf
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"

export PATH="$HOME/.local/bin:$PATH"

# Environment variables
export EDITOR=nvim
export XDG_DESKTOP_PORTAL_BACKEND=xdg-desktop-portal-hyprland

# History
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Interactive session configuration
if [[ -o interactive ]]; then
    # No greeting
    unsetopt zsh_greeting 2>/dev/null

    # Use starship
    eval "$(starship init zsh)"

    # Quickshell sequences
    if [[ -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt ]]; then
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    fi

    # Functions
    function y {
        local tmp=$(mktemp -t "yazi-cwd.XXXXXX")
        yazi "$@" --cwd-file="$tmp"
        if cwd=$(cat -- "$tmp") && [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }

    # Aliases
    alias clear="printf '\033[2J\033[3J\033[1;1H'" # fix: kitty doesn't clear properly
    alias celar="printf '\033[2J\033[3J\033[1;1H'"
    alias claer="printf '\033[2J\033[3J\033[1;1H'"
    alias ls='eza --icons'
    alias lsa='eza --icons --all'
    alias q='qs -c ii'
    alias cl='clear'
    alias cd='z'
    alias g='gemini'
    alias t='tmuxinator'
    alias dpip='/home/host4/Projects/datalisis/bin/pip'
    alias dpy='/home/host4/Projects/datalisis/bin/python'

    # Abbreviations (converted to aliases - for true fish-like abbreviations, use zsh-abbr plugin)
    alias fan="sudo echo 'level ' | sudo tee /proc/acpi/ibm/fan "
    alias s='sudo -E -s'
    alias lg='lazygit'
    alias ys='yay -S --needed --noconfirm'
    alias yr='yay -Rns'
    alias yy='yay'
    alias cx='chmod +x'
    alias ch='cd ~/.config/hypr/'
    alias td='tmuxinator datalisis'
    alias o='opencode'
    alias or='opencode run'
    alias n='nvim'
fi

# Auto-Warpify
printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'


[ -f "/home/host2/.ghcup/env" ] && . "/home/host2/.ghcup/env" # ghcup-envexport PATH="/usr/lib/jvm/java-26-openjdk/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
