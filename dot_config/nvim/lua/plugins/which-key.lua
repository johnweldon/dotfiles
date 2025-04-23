require("lib")

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
    -- print("which-key options", DebugDump(opts.icons))
    -- copilot rules
    local copilotRule = { plugin = "copilot.lua", icon = "", color = "orange" }
    local existingIcons = opts.icons or {}
    local existingRules = existingIcons.rules or {}
    existingRules[#existingRules + 1] = copilotRule
    opts.icons = existingIcons

    -- Debug
    -- print("which-key final options", DebugDump(opts.icons))
  end,
}
