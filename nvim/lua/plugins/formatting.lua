-- Exactly one project formatter per buffer, chosen by config presence:
--   biome-check  when biome.json(c) is found upward     (biome extra sets require_cwd)
--   oxfmt        when .oxfmtrc.json(c) is found upward  (require_cwd + narrowed cwd below)
--   prettier     when a prettier config is found         (vim.g.lazyvim_prettier_needs_config)
--   otherwise LSP fallback.
-- The extras append in import order (prettier, biome-check, oxfmt) and conform runs every available
-- formatter unless stop_after_first is set, so a repo with biome.jsonc AND .prettierrc
-- would run prettier on TS. Rewrite the order and stop after the first available one.
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.oxfmt = {
      require_cwd = true,
      cwd = require("conform.util").root_file({ ".oxfmtrc.json", ".oxfmtrc.jsonc" }),
    }
    for ft, list in pairs(opts.formatters_by_ft) do
      if vim.tbl_contains(list, "biome-check") or vim.tbl_contains(list, "oxfmt") then
        local ordered = {}
        for _, name in ipairs({ "biome-check", "oxfmt", "prettier" }) do
          if vim.tbl_contains(list, name) then
            ordered[#ordered + 1] = name
          end
        end
        ordered.stop_after_first = true
        opts.formatters_by_ft[ft] = ordered
      end
    end
  end,
}
