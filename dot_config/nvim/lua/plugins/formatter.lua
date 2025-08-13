return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 6000,
      },
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },
}
