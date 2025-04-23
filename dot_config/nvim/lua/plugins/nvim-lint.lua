require("lib")

return {
  "mfussenegger/nvim-lint",
  optional = true,
  -- opts = {
  --   linters = {
  --     ["markdownlint-cli2"] = {
  --       args = { "--config", HOME .. "/.config/markdownlint-cli2.yaml", "--" },
  --     },
  --   },
  -- },
  opts = function(_, opts)
    -- Update Linters
    local linters = opts.linters or {}
    local HOME = os.getenv("HOME") or "."
    linters["markdownlint-cli2"] = {
      args = { "--config", HOME .. "/.config/markdownlint-cli2.yaml", "--" },
    }
    opts.linters = linters

    -- Debug
    --print("linter options", DebugDump(opts))
  end,
}
