
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by `rbenv init` on Wed Nov 27 22:48:14 CET 2024
eval "$(rbenv init - --no-rehash zsh)"

# Created by `pipx` on 2025-07-27 11:02:03
export PATH="$PATH:$HOME/.local/bin"

# macOS path_helper (/etc/zprofile) moves the system dirs ahead of the node that .zshenv put on PATH.
# Put it back in front so nothing in /usr/local/bin or /opt/homebrew/bin can shadow nvm's node.
[[ -n $NVM_BIN ]] && path=("$NVM_BIN" $path)
