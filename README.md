# dotfiles

Public macOS dotfiles for a React Native / TypeScript workflow. Zed stays the default editor; Neovim (LazyVim) is the opt-in one this repo exists to set up. Conventions for agent sessions live in [AGENTS.md](AGENTS.md).

| Repo path | Symlinked to | What it does |
|---|---|---|
| `nvim/` | `~/.config/nvim` | LazyVim config: vtsls, Biome, oxlint/oxfmt, Tailwind, Copilot, Claude Code, RN script runner |
| `ghostty/config` | `~/.config/ghostty/config` | JetBrainsMono Nerd Font 16, Dracula, left Option as Alt |
| `zsh/.zshenv`, `zsh/.zprofile`, `zsh/.zshrc` | `~/.zshenv`, `~/.zprofile`, `~/.zshrc` | oh-my-zsh, nvm loaded once, `EDITOR=zed --wait`, sources `~/.zshrc.local` last |
| `git/gitconfig`, `git/ignore` | `~/.gitconfig`, `~/.config/git/ignore` | identity, `zed --wait` as editor, global ignores |
| `Brewfile` | not linked | everything the files above need, installed by `install.sh` |

Secrets never live here. `~/.zshrc.local` (untracked, `chmod 600`) holds machine-local exports such as private npm registry tokens and is sourced at the end of `.zshrc`.

## Bootstrap a fresh Mac

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone git@github.com:idlework/dotfiles.git ~/Development/me/dotfiles
install -m 600 /dev/null ~/.zshrc.local   # add your exports here
~/Development/me/dotfiles/install.sh
mkdir -p ~/.nvm && nvm install 24
```

`install.sh` is idempotent: it symlinks every managed file (an existing real file is moved to `<file>.bak`, never deleted) and runs `brew bundle`, which installs only what is missing and never upgrades. Then:

1. Open a new Ghostty window (or press `cmd+shift+,`) to pick up the font and theme.
2. Run `nvim`. The first start installs plugins, compiles treesitter parsers and lets Mason install the language servers; give it a minute.
3. `:LazyHealth` should be green. `:Copilot auth` signs in to GitHub Copilot once.

## Learning Neovim from Zed

The leader key is `<Space>`. Press it and wait: which-key lists every group. `<leader>sk` searches all keymaps by description, `<leader>?` shows the ones for the current buffer. The mouse works everywhere. Thirty minutes of `:Tutor` pays for itself, and `:Precognition toggle` shows motion hints (`w`, `b`, `e`, `^`, `$`, `f`, `t`) on the current line until you turn it off. `<Esc>` leaves insert mode and clears search highlights; `<Esc><Esc>` leaves terminal mode.

| Zed | Neovim (LazyVim) |
|---|---|
| Cmd+P file finder | `<leader><space>` (repo root), `<leader>fr` recent, `<leader>,` open buffers |
| Cmd+Shift+F project search | `<leader>/` live grep, `<leader>sw` word under cursor, `<leader>sr` search and replace |
| Cmd+Shift+P command palette | `:` for a command, `<leader>sC` commands, `<leader>sk` keymaps |
| Cmd+Shift+G git panel | `<leader>gg` lazygit, `<leader>gs` git status, `]h` / `[h` next / previous hunk, `<leader>ghs` stage hunk |
| Cmd+Shift+R rename symbol | `<leader>cr`; rename the file with import updates: `<leader>cR` |
| ctrl-alt-down go to definition | `gd` (`<C-o>` jumps back), `gr` references, `gI` implementation, `gy` type definition |
| Cmd+B / Cmd+Shift+E project panel | `<leader>e` (repo root), `<leader>E` (cwd); inside: `a` add, `d` delete, `r` rename, `?` help |
| Cmd+/ comment | `gcc` line, `gc` plus a motion or a visual selection |
| Cmd+D select next occurrence | no multi-cursor: `*` then `cgn`, type the replacement, `.` repeats; or `:%s/old/new/gc` |
| Cmd+S save | `<C-s>` or `:w` (formats on save) |
| Cmd+W close tab | `<leader>bd`; `<S-h>` / `<S-l>` switch buffers |
| Cmd+Z / Cmd+Shift+Z | `u` / `<C-r>` |
| hover, signature | `K`, `gK` |
| code actions | `<leader>ca`; source actions such as organize or remove unused imports `<leader>cA`; add missing imports `<leader>cM`; fix all `<leader>cD` |
| format | `<leader>cf`, also on save; `:ConformInfo` shows which formatter applies |
| next / previous diagnostic | `]d` / `[d`, errors only `]e` / `[e`, `<leader>cd` line, `<leader>xx` all (Trouble) |
| git blame | inline on the current line; `<leader>gb` line history, `<leader>gB` open on GitHub |
| terminal | `<C-/>` toggles one at the repo root |
| Claude Code | `<leader>ac` toggle, `<leader>as` send selection (or add the file from the explorer), `<leader>ab` add buffer, `<leader>aa` / `<leader>ad` accept / deny diff, `<leader>ar` resume |
| Copilot | `<Tab>` accepts ghost text, `<M-]>` / `<M-[>` next / previous suggestion, `:Copilot status` |
| windows | `<C-h>` `<C-j>` `<C-k>` `<C-l>` move, `<leader>\|` / `<leader>-` split, `<leader>wd` close |
| quit | `<leader>qq` |

Line numbers are absolute like Zed; `<leader>uL` switches to relative numbers once counts and motions become habit.

## React Native workflow

- `<leader>rr` lists the scripts of the nearest `package.json` (in a monorepo that is the app package) and runs the chosen one in a terminal at that package with the package manager from the `packageManager` field or the lockfile. `start` and `ios` keep running; pressing `<leader>rr` for the same script again toggles that terminal. Finished runs stay open to read; the next run starts fresh.
- `<leader>rt` runs `tsc --noEmit` for the nearest `tsconfig.json` into the quickfix list: `]q` / `[q` walk the errors, `<leader>xq` lists them.
- Lint diagnostics come from the project's own Biome, oxlint or ESLint through their language servers, so squiggles match `pnpm check`.
- Formatting on save runs exactly one project formatter, picked by config presence:

| Found upward from the file | Formatter |
|---|---|
| `biome.json` or `biome.jsonc` | project Biome (`biome check --write`) |
| `.oxfmtrc.json` or `.oxfmtrc.jsonc` | project oxfmt |
| a Prettier config | Prettier (markdown, yaml, css and friends) |
| none | the language server |

- Tailwind class completion and lint work in `className` and inside `cn`, `cva`, `clsx` and `twMerge` calls (NativeWind, UniWind).
- Simulators, Metro logs, Maestro and Fastlane stay in Ghostty tabs, unchanged.

## Git

`<leader>gg` opens lazygit; files it opens land in the running Neovim. Commit messages from the shell still open in Zed (`core.editor = zed --wait`). `gh`, `gh stack` and worktrees are unaffected.

## Updating

| What | How |
|---|---|
| Neovim plugins | `:Lazy update`, then commit `nvim/lazy-lock.json` as `chore(nvim): update plugins` |
| Extras | `:LazyExtras`, then commit `nvim/lazyvim.json` |
| Language servers, formatters | `:Mason` |
| Treesitter parsers | `:TSUpdate` |
| Health | `:LazyHealth` |
| Brew packages | edit `Brewfile`, run `./install.sh` |
| A new managed file | add it to `install.sh`, run `./install.sh` |

## Troubleshooting

| Symptom | Fix |
|---|---|
| Mason cannot install npm packages | node is not on PATH; start Neovim from Ghostty, check `:checkhealth mason` |
| Copilot says not signed in | `:Copilot auth` |
| Treesitter parser build errors | `tree-sitter --version`, `xcode-select --install`, then `:TSUpdate` |
| Broken icons | the Nerd Font is not active: `ghostty +list-fonts \| grep -i jetbrains`, then `cmd+shift+,` |
| `<A-j>` does nothing | `macos-option-as-alt` in `ghostty/config` (`left`, `right` or `true`) |
| Nothing formats on save | `:ConformInfo` and `:LazyFormatInfo` show what applies and why |
| No diagnostics | `<leader>cl` shows which servers attached; `:LazyRoot` shows the detected root |

## Rollback

`install.sh` backed up every replaced file next to its original: `~/.zshrc.bak`, `~/.zprofile.bak`, `~/.zshenv.bak`, `~/.gitconfig.bak`, `~/.config/git/ignore.bak`. Move one back to undo that piece. `~/.config/nvim` and `~/.config/ghostty/config` are plain symlinks; removing them restores the previous state, and `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim` wipes the plugin data.
