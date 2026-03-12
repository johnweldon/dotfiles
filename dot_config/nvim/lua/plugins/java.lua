-- Fix for Java LSP dynamic capability registration errors
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {
          capabilities = {
            workspace = {
              configuration = true,
              didChangeConfiguration = { dynamicRegistration = false },
              didChangeWatchedFiles = { dynamicRegistration = false },
            },
          },
        },
      },
    },
    init = function()
      local original_register_capability = vim.lsp.handlers["client/registerCapability"]

      vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client and client.name ~= "jdtls" then
          local handler = original_register_capability or vim.lsp.handlers._default["client/registerCapability"]
          return handler(err, result, ctx, config)
        end
        -- jdtls: only forward well-formed registration requests
        if result and result.registrations and type(result.registrations) == "table" then
          local handler = original_register_capability or vim.lsp.handlers._default["client/registerCapability"]
          return handler(err, result, ctx, config)
        end
        return nil
      end
    end,
  },
}
