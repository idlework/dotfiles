return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- NativeWind / UniWind: complete and lint classes inside helper calls too.
      -- className attributes are covered by the server defaults; these are the helper names used across the projects.
      tailwindcss = {
        settings = { tailwindCSS = { classFunctions = { "cn", "cva", "clsx", "twMerge" } } },
      },
    },
  },
}
