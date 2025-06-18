-- require("lib")

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
      local gopls = opts.servers.gopls
        or {
          settings = {
            gopls = {
              analyses = {},
            },
          },
        }
      opts.servers.gopls = gopls

      -- Build Flags
      local newBuildFlag = "-tags=integration"
      local buildFlags = gopls.settings.gopls.buildFlags or {}
      buildFlags[#buildFlags + 1] = newBuildFlag
      opts.servers.gopls.settings.gopls.buildFlags = buildFlags

      -- FieldAlignment
      opts.servers.gopls.settings.gopls.analyses.fieldalignment = false

      -- DebugDump(opts)
    end,
  },
}
