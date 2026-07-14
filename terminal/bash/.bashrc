# ~/.bashrc

case $- in
  *i*) ;;
  *) return ;;
esac

export EDITOR=nvim
export VISUAL=nvim

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.cargo/env"
fi

HISTCONTROL=ignoredups:erasedups
HISTSIZE=-1
HISTFILESIZE=-1
shopt -s histappend checkwinsize
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status --short --branch'
alias gl='git log --graph --oneline --decorate'
alias lg='lazygit'

if [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck source=/dev/null
  . /usr/share/bash-completion/bash_completion
fi

if command -v fzf >/dev/null 2>&1; then
  if _fzf_bash="$(fzf --bash 2>/dev/null)" && [ -n "$_fzf_bash" ]; then
    eval "$_fzf_bash"
  else
    for _fzf_bindings in \
      /usr/share/fzf/key-bindings.bash \
      /usr/share/fzf/shell/key-bindings.bash \
      /usr/share/doc/fzf/examples/key-bindings.bash \
      "$HOME/.fzf/shell/key-bindings.bash"; do
      if [ -f "$_fzf_bindings" ]; then
        # shellcheck source=/dev/null
        . "$_fzf_bindings"
        break
      fi
    done
  fi
fi
unset _fzf_bash _fzf_bindings

bind "set completion-ignore-case on"
