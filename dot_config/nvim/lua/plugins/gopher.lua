require("lib")

return {
  {
    "neovim/nvim-lspconfig",
    -- opts = {
    --   servers = {
    --     gopls = {
    --       settings = {
    --         gopls = {
    --           buildFlags = { "-tags=integration" },
    --           analyses = {
    --             fieldalignment = false,
    --           },
    --         },
    --       },
    --     },
    --   },
    -- },
    opts = function(_, opts)
      -- Build Flags
      local newBuildFlag = "-tags=integration"
      local buildFlags = opts.servers.gopls.settings.gopls.buildFlags or {}
      buildFlags[#buildFlags + 1] = newBuildFlag
      opts.servers.gopls.settings.gopls.buildFlags = buildFlags
      -- FieldAlignment
      opts.servers.gopls.settings.gopls.analyses.fieldalignment = false

      -- Debug
      -- print("final options lsp", DebugDump(opts))
    end,
  },
}
