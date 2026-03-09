function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

# to set fish as the default shell use:
# chsh -s /usr/bin/fish
# ------------------------------------

fzf --fish | source
zoxide init fish | source
# is init fish
set -gx EDITOR nvim
set -Ux XDG_DESKTOP_PORTAL_BACKEND xdg-desktop-portal-hyprland

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Functions
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function n
        kitty @ set-spacing margin=0
        command nvim $argv
        kitty @ set-spacing margin=10
    end

    function o
        kitty @ set-spacing margin=0
        command opencode $argv
        kitty @ set-spacing margin=10
    end

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias lsa 'eza --icons --all'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    alias cl 'clear && fish'
    alias cd z
    alias g gemini
    alias t tmuxinator
    alias dpip /home/host4/Projects/datalisis/bin/pip
    alias dpy /home/host4/Projects/datalisis/bin/python

    # Abbreviation
    abbr -a fan --set-cursor "sudo echo 'level %' | sudo tee /proc/acpi/ibm/fan "
    abbr -a s sudo -E -s
    abbr -a lg lazygit
    abbr -a ys yay -S --needed --noconfirm
    abbr -a yy yay
    abbr -a cx chmod +x
    abbr -a ch 'cd ~/.config/hypr/ && '
    abbr -a td tmuxinator datalisis
end
