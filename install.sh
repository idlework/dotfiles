#!/usr/bin/env bash
# Symlink dotfiles into $HOME and install Homebrew packages. Idempotent; never deletes
# (an existing real file/dir is moved to <target>.bak). Never touches ~/.zshrc.local.
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES=$PWD

link() { # link <repo path> <target path>
  local src="$DOTFILES/$1" dst="$2"
  [ -e "$src" ] || {
    echo "skip $1 (not in repo yet)"
    return
  }
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    [ -e "$dst.bak" ] && {
      echo "refusing to overwrite $dst.bak"
      exit 1
    }
    mv "$dst" "$dst.bak" && echo "backed up $dst -> $dst.bak"
  fi
  ln -sfn "$src" "$dst" && echo "linked $dst -> $src"
}

link nvim "$HOME/.config/nvim"
link ghostty/config "$HOME/.config/ghostty/config"
link zsh/.zshenv "$HOME/.zshenv"
link zsh/.zprofile "$HOME/.zprofile"
link zsh/.zshrc "$HOME/.zshrc"
link git/gitconfig "$HOME/.gitconfig"
link git/ignore "$HOME/.config/git/ignore"

command -v brew >/dev/null || {
  echo "Homebrew missing: https://brew.sh"
  exit 1
}
# install what is missing, never upgrade what is already there
HOMEBREW_BUNDLE_NO_UPGRADE=1 brew bundle --file="$DOTFILES/Brewfile"

cat <<'MSG'

Next steps:
  - secrets: ~/.zshrc.local (chmod 600) is sourced by .zshrc when present
  - Ghostty: open a new window (or cmd+shift+,) to pick up font/theme
  - nvim: first launch installs plugins and parsers, then :LazyHealth and :Copilot auth
MSG
