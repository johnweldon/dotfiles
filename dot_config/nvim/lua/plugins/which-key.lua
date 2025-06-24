local lib = require("lib")
local debug = lib.create_logger("which-key")

return {
  "folke/which-key.nvim",
  -- opts = {
  --   icons = {
  --     rules = {
  --       { plugin = "copilot.lua", icon = "", color = "orange" },
  --     },
  --   },
  -- },
  opts = function(_, opts)
    debug.log("Initial options", opts.icons)
    -- copilot rules
    local copilotRule = { plugin = "copilot.lua", icon = "", color = "orange" }
    local existingIcons = opts.icons or {}
    local existingRules = existingIcons.rules or {}
    existingRules[#existingRules + 1] = copilotRule
    opts.icons = existingIcons

    debug.log("Final options", opts.icons)

    return opts
  end,
}
