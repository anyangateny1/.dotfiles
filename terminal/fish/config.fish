# ~/.config/fish/config.fish

set -gx EDITOR nvim
set -gx VISUAL nvim

function lpwd --on-variable PWD
    set -l lower (string lower $PWD)
    echo $lower
end

fish_add_path -g "$HOME/.local/bin"

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
else if test -d "$HOME/.cargo/bin"
    fish_add_path -g "$HOME/.cargo/bin"
end

if status is-interactive
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias gs='git status --short --branch'
    alias gl='git log --graph --oneline --decorate'
    alias lg='lazygit'

    set -g fish_greeting

    if command -q fzf
        fzf --fish 2>/dev/null | source
    else if test -f /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish
        source /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish
    end
end
