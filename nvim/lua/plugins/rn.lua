-- Keymaps for lua/rn.lua (package.json script runner + tsc quickfix). <leader>r is unused by LazyVim core.
return {
  { "folke/which-key.nvim", opts = { spec = { { "<leader>r", group = "run" } } } },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>rr",
        function()
          require("rn").run_script()
        end,
        desc = "Run package.json script",
      },
      {
        "<leader>rt",
        function()
          require("rn").typecheck()
        end,
        desc = "Typecheck (tsc to quickfix)",
      },
    },
  },
}
