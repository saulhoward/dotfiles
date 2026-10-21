autoload -U colors && colors
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' %b'
setopt PROMPT_SUBST
function () {
  local prefix=''
  if [[ -n $IN_NIX_SHELL ]]; then
      local label='nix-shell'
      [[ -n $name && $name != $label ]] && label="$label:$name"
      prefix="%{$fg[green]%}$label "
  fi
  if [[ -n $SSH_TTY ]]; then
      prefix+='%B%{$fg[magenta]%}%n@%m '
  fi
  PROMPT=$prefix'%b%{$fg[yellow]%}%c%{$fg[white]%}${vcs_info_msg_0_} %B%{$fg[green]%}$%b '
}
