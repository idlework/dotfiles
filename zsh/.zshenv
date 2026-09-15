# Runs for every zsh, interactive or not, so keep it cheap. PATH entries are deduplicated.
typeset -U path fpath

# nvm fast path: the default node goes on PATH now, the real nvm loads on the first `nvm` call
# (saves ~0.2 s per shell; nvm_auto scanned the versions on every start).
# NVM_BIN is exported so .zprofile can put it back in front after macOS path_helper reorders PATH.
export NVM_DIR="$HOME/.nvm"
() {
  local d
  read -r d 2>/dev/null < "$NVM_DIR/alias/default"
  local -a v
  v=("$NVM_DIR"/versions/node/v*(N/nOn)) # newest installed first
  [[ -n "$d" && -d "$NVM_DIR/versions/node/$d" ]] && v=("$NVM_DIR/versions/node/$d")
  (( $#v )) || return
  export NVM_BIN="$v[1]/bin" # what nvm itself exports once loaded
  path=("$NVM_BIN" $path)
}
nvm() {
  unfunction nvm
  . "$NVM_DIR/nvm.sh" 2>/dev/null || . /opt/homebrew/opt/nvm/nvm.sh
  nvm "$@"
}
