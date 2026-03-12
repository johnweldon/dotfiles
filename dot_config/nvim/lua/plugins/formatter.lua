return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 6000,
      },
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        go = { "goimports", "gofumpt" },
        json = { "jq" },
        lua = { "stylua" },
        markdown = { "prettier_markdown", "unescape_globs" },
        python = { "black", "ruff_fix" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        terraform = { "terraform_fmt" },
        toml = { "taplo" },
        yaml = { "yq" },
        zig = { "zigfmt" },
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
        jq = {
          args = { "--indent", "2", "." },
        },
        shfmt = {
          prepend_args = { "-i", "2" },
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
