-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Already LazyVim defaults, not repeated here: mouse = "a", clipboard = "unnamedplus" (unless SSH),
-- vim.g.autoformat = true, number = true.

-- Repo root first. In monorepos the LSP root is the package dir, which would scope <leader><space> and
-- <leader>/ to one package. vim.fs.find has no type filter, so a worktree's .git *file* matches too.
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }

-- Prettier only where a prettier config exists; biome/oxfmt repos otherwise.
vim.g.lazyvim_prettier_needs_config = true

-- Copilot as inline ghost text (Tab accepts) instead of a blink.cmp menu source.
vim.g.ai_cmp = false

-- Absolute line numbers like Zed; relative numbers pay off once counts + motions are habit. Toggle: <leader>uL
vim.opt.relativenumber = false
