return {
  {
    "mason-org/mason.nvim",
    --version = "^1.0.0",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    --version = "^1.0.0",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {},
  },
}
