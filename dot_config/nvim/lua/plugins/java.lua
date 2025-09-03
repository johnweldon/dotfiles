-- Fix for Java LSP dynamic capability registration errors
return {
  {
    "LazyVim/LazyVim",
    config = function()
      -- Override the problematic register_capability handler in LazyVim
      local original_register_capability = vim.lsp.handlers["client/registerCapability"]

      vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx, config)
        -- Check if result.registrations exists and is a table before calling original handler
        if result and result.registrations and type(result.registrations) == "table" then
          if original_register_capability then
            return original_register_capability(err, result, ctx, config)
          else
            return vim.lsp.handlers._default["client/registerCapability"](err, result, ctx, config)
          end
        end
        -- Silently ignore malformed registration requests
        return nil
      end
    end,
  },
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
  },
}

