# Runs for every zsh, interactive or not, so keep it cheap. PATH entries are deduplicated.
typeset -U path fpath

# nvm fast path: the default node goes on PATH now, the real nvm loads on the first `nvm` call
# (saves ~0.2 s per shell; nvm_auto scanned the versions on every start).
export NVM_DIR="$HOME/.nvm"
() {
  local d
  read -r d 2>/dev/null < "$NVM_DIR/alias/default"
  local -a v
  v=("$NVM_DIR"/versions/node/v*(N/nOn)) # newest installed first
  [[ -n "$d" && -d "$NVM_DIR/versions/node/$d" ]] && v=("$NVM_DIR/versions/node/$d")
  (( $#v )) && path=("$v[1]/bin" $path)
}
nvm() {
  unfunction nvm
  . "$NVM_DIR/nvm.sh" 2>/dev/null || . /opt/homebrew/opt/nvm/nvm.sh
  nvm "$@"
}
