# AGENTS.md

Public macOS dotfiles (GitHub `idlework`). Zed is the default editor; Neovim (LazyVim) is opt-in.

## Layout

| Repo path | Symlinked to | Read by |
|---|---|---|
| `nvim/` | `~/.config/nvim` | Neovim (LazyVim) |
| `ghostty/config` | `~/.config/ghostty/config` | Ghostty |
| `zsh/.zshenv`, `zsh/.zprofile`, `zsh/.zshrc` | `~/.zshenv`, `~/.zprofile`, `~/.zshrc` | zsh |
| `git/gitconfig` | `~/.gitconfig` | git |
| `git/ignore` | `~/.config/git/ignore` | git (global excludes) |
| `Brewfile` | not linked | `brew bundle` via `install.sh` |

`install.sh` creates the links (backing up real files to `<target>.bak`) and runs `brew bundle`.

## Conventions

- Conventional commits with a scope: `feat(nvim): ...`, `chore(brew): ...`. Scopes: `nvim`, `zsh`, `git`, `ghostty`, `brew`, `install`, `docs`.
- Commit straight to `main`; no pull requests for this solo repo.
- Never add `Co-Authored-By` or any AI attribution trailer to commits.
- Never use the em dash character; use `-`.
- No secrets in the repo. Machine-local secrets live in `~/.zshrc.local` (untracked, mode 600), sourced last by `zsh/.zshrc`. Before committing run `git grep -nE 'github_pat_[A-Za-z0-9_]{10,}|TOKEN=.?[A-Za-z0-9]{8,}'` and expect no output.
- Never automate anything that reads or writes `~/.zshrc.local`.
- No drive-by cleanups in `zsh/` and `git/`; they mirror the machine and change only for a reason stated in the commit.

## Neovim

- LazyVim v16 on the starter layout. Extras are enabled only through `nvim/lazyvim.json` (keep `install_version: 8`; commit the file after `:LazyExtras` rewrites it).
- One spec per file under `nvim/lua/plugins/`, each plugin and option with a one-line reason in a comment.
- Prefer a LazyVim extra over hand-wiring a plugin.
- `nvim/lazy-lock.json` is committed; after `:Lazy update` commit it as `chore(nvim): update plugins`.
- Lua is formatted by stylua (`nvim/stylua.toml`, on save inside Neovim).
- Known coupling: `nvim/lua/plugins/formatting.lua` rewrites the JS/TS formatter lists to `biome-check`, `oxfmt`, `prettier` with `stop_after_first`; a new formatter extra for those filetypes must be added there.
- Not wanted: tmux/zellij, nvim-dap, overseer, other AI plugins, neo-tree.

## Verify

- `shellcheck install.sh`
- `./install.sh` twice; the second run prints only `linked` lines and creates no `.bak` files.
- `nvim --headless "+Lazy! sync" +qa`, then interactive `:LazyHealth`.
- `nvim --headless -u NONE --cmd "set rtp+=nvim" -l nvim/tests/rn_test.lua` (script runner detection).
- `time zsh -i -c exit` (baseline 1.2 s on 2026-09-14).
- `ghostty +show-config | grep -E "^(font-family|font-size|theme|macos-option-as-alt)"`
