# Plain zsh, no framework. What oh-my-zsh used to provide lives here or in the tools sourced at the end:
# git aliases in ~/.config/zsh/git.zsh (vendored oh-my-zsh git plugin), prompt by starship (~/.config/starship.toml),
# node via the nvm fast path in .zshenv, brew shellenv and rbenv in .zprofile.

# Options and history
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments
setopt extended_history share_history hist_ignore_dups hist_ignore_space hist_expire_dups_first hist_verify
unsetopt flow_control # frees Ctrl-S and Ctrl-Q
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# ls colors (oh-my-zsh values)
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
alias ls='ls -G'
alias ll='ls -lh'

# Completion: one compinit, the security audit once a day, results cached
fpath=(/opt/homebrew/share/zsh/site-functions "$HOME/.cache/zsh/completions" $fpath)
if [[ ! -f "$HOME/.cache/zsh/completions/_pnpm" ]] && command -v pnpm >/dev/null; then
  mkdir -p "$HOME/.cache/zsh/completions"
  pnpm completion zsh >"$HOME/.cache/zsh/completions/_pnpm" 2>/dev/null || rm -f "$HOME/.cache/zsh/completions/_pnpm"
fi
zmodload zsh/complist
autoload -Uz compinit
if [[ -n "$HOME"/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Keys: emacs mode, Up/Down search history by the typed prefix, word jumps with Option or Ctrl and arrows
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Editors: Zed stays the default, Neovim is opt-in
export EDITOR="zed --wait"
export VISUAL="$EDITOR"
export REACT_EDITOR=zed

# Android / Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export PATH="$PATH:$JAVA_HOME/bin"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"

# Other tools on PATH
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/google-cloud-sdk/path.zsh.inc"
typeset -U path # the export PATH= lines above drop the uniqueness flag set in .zshenv; dedupe once

# Aliases
alias zshconfig="zed ~/.zshrc"
alias claude="claude --effort max"
alias ios-simulator='open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'
alias android-emulator='$ANDROID_HOME/emulator/emulator -avd Pixel_9_pro_api_35'
alias git-clean-branches="git remote prune origin | git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d"
alias px="pnpm exec"

# Git aliases (oh-my-zsh git plugin, vendored); needs compinit first because it calls compdef
source "$HOME/.config/zsh/git.zsh"

# fzf: Ctrl-R history, Ctrl-T file paths, Alt-C directories (only with a terminal: no zle without one)
[[ -t 0 ]] && source <(fzf --zsh)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # keep last: it wraps the widgets above

# Machine-local secrets and overrides (untracked)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
