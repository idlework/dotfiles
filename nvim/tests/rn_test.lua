-- Run from the repo root: nvim --headless -u NONE --cmd "set rtp+=nvim" -l nvim/tests/rn_test.lua
local rn = require("rn")
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
tmp = vim.uv.fs_realpath(tmp) -- Neovim resolves /var -> /private/var in buffer names
vim.fn.mkdir(tmp .. "/apps/mobile", "p")
vim.fn.writefile({ "" }, tmp .. "/pnpm-lock.yaml")
vim.fn.writefile({ '{"scripts":{"ios":"expo run:ios","start":"expo start"}}' }, tmp .. "/apps/mobile/package.json")
vim.fn.writefile({ "" }, tmp .. "/apps/mobile/App.tsx")
vim.cmd.edit(tmp .. "/apps/mobile/App.tsx")

local dir, scripts, pm = rn.project()
assert(dir == tmp .. "/apps/mobile", "dir: " .. dir)
assert(scripts.ios == "expo run:ios", "scripts: " .. vim.inspect(scripts))
assert(pm == "pnpm", "lockfile at the workspace root should win: " .. pm)

vim.fn.writefile({ '{"packageManager":"yarn@4.11.0","scripts":{}}' }, tmp .. "/apps/mobile/package.json")
local _, _, pm2 = rn.project()
assert(pm2 == "yarn", "packageManager field should beat the lockfile: " .. pm2)

vim.fn.delete(tmp, "rf")
print("rn_test ok")
