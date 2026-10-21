autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zmodload zsh/complist
function () {
  setopt local_options extended_glob
  local dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
  [[ -d ${dump:h} ]] || mkdir -p "${dump:h}"
  # Full rebuild + security audit once a day, or when a completion dir changes
  # (e.g. a new package installed); otherwise trust the cache.
  local fresh=1 dir
  [[ -n $dump(#qN.mh-24) ]] || fresh=0
  for dir in $fpath; do
    [[ $dir -nt $dump ]] && fresh=0 && break
  done
  if (( fresh )); then
    compinit -C -d "$dump"
  else
    compinit -i -d "$dump" && touch "$dump"
  fi
}
_comp_options+=(globdots)		# Include hidden files.
