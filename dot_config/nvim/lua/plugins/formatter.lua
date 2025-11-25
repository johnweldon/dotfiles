return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 6000,
      },
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        markdown = { "prettier_markdown", "unescape_globs" },
      },
      formatters = {
        prettier_markdown = {
          command = "prettier",
          args = {
            "--prose-wrap",
            "preserve",
            "--parser",
            "markdown",
          },
        },
        unescape_globs = {
          command = "sed",
          args = { "-E", "s/\\\\\\*/*/g" },
          stdin = true,
        },
      },
    },
  },
}
