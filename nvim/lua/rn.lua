-- React Native / TS project runner. No plugin: package.json scripts via vim.ui.select (snacks) into a
-- Snacks.terminal at the package root, plus tsc into the quickfix list via the built-in :compiler tsc.
-- Keymaps live in lua/plugins/rn.lua; tests/rn_test.lua covers project().
local M = {}

local lockfiles = {
  ["pnpm-lock.yaml"] = "pnpm",
  ["yarn.lock"] = "yarn",
  ["package-lock.json"] = "npm",
  ["bun.lock"] = "bun",
  ["bun.lockb"] = "bun",
}

-- Nearest package.json upward from the buffer: in a monorepo that is the app package owning start/ios/android.
-- Returns dir, scripts, package manager (packageManager field, else the nearest lockfile upward, else pnpm).
function M.project()
  local dir = vim.fs.root(0, "package.json") or vim.uv.cwd()
  local ok, pkg = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(dir .. "/package.json"), "\n"))
  end)
  pkg = ok and pkg or {}
  local pm = type(pkg.packageManager) == "string" and pkg.packageManager:match("^(%a+)@")
  if not pm then
    local lock = vim.fs.find(vim.tbl_keys(lockfiles), { upward = true, path = dir })[1]
    pm = lock and lockfiles[vim.fs.basename(lock)] or "pnpm"
  end
  return dir, pkg.scripts or {}, pm
end

local function run_in_terminal(cmd, cwd)
  local opts = { cwd = cwd, auto_close = false } -- keep output readable after the process exits
  local term = Snacks.terminal.get(cmd, vim.tbl_extend("force", opts, { create = false }))
  if term and vim.fn.jobwait({ vim.bo[term.buf].channel }, 0)[1] ~= -1 then
    term:close({ buf = true }) -- previous run finished: start fresh instead of re-showing a dead terminal
  end
  Snacks.terminal.toggle(cmd, opts) -- long-running scripts (start, ios) toggle the same terminal
end

function M.run_script()
  local dir, scripts, pm = M.project()
  local names = vim.tbl_keys(scripts)
  if #names == 0 then
    return vim.notify("No scripts in " .. dir .. "/package.json", vim.log.levels.WARN)
  end
  table.sort(names)
  vim.ui.select(names, {
    prompt = pm .. " run",
    format_item = function(name)
      return name .. "  " .. scripts[name]
    end,
  }, function(name)
    if name then
      run_in_terminal(pm .. " run " .. name, dir)
    end
  end)
end

function M.typecheck()
  local dir = vim.fs.root(0, "tsconfig.json")
  if not dir then
    return vim.notify("No tsconfig.json found", vim.log.levels.WARN)
  end
  -- Call the project's own tsc directly: `npm exec tsc -p dir` would swallow -p as npm's --package flag.
  local tsc
  for _, nm in ipairs(vim.fs.find("node_modules", { upward = true, path = dir, type = "directory", limit = math.huge })) do
    if vim.fn.executable(nm .. "/.bin/tsc") == 1 then
      tsc = nm .. "/.bin/tsc"
      break
    end
  end
  if not tsc then
    return vim.notify("No node_modules/.bin/tsc above " .. dir, vim.log.levels.WARN)
  end
  -- runtime/compiler/tsc.vim reads b:tsc_makeprg; its errorformat needs --pretty false.
  vim.b.tsc_makeprg = vim.fn.shellescape(tsc) .. " --noEmit --pretty false -p " .. vim.fn.shellescape(dir)
  vim.cmd.compiler("tsc")
  vim.cmd("make!") -- ponytail: synchronous (5-20 s on RN apps); upgrade path is vim.system + setqflist
  vim.cmd(#vim.fn.getqflist() > 0 and "copen" or "cclose")
end

return M
