local lib = require("lib")
local debug = lib.create_logger("nvim-lint")

return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    -- Update Linters
    local linters = opts.linters or {}
    local HOME = os.getenv("HOME") or vim.fn.expand("~")
    local config_path = HOME .. "/.config/markdownlint-cli2.yaml"

    -- Validate config file exists
    if vim.fn.filereadable(config_path) == 0 then
      vim.notify("Markdownlint config not found: " .. config_path, vim.log.levels.WARN)
    end

    linters["markdownlint-cli2"] = {
      args = { "--config", config_path, "--" },
    }
    opts.linters = linters

    -- Debug logging
    debug.log("Configured linter options", opts)

    return opts
  end,
}
