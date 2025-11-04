return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      trigger = {
        show_on_keyword = true,
        show_on_insert_on_trigger_character = true,
      },
      menu = {
        auto_show = true,
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          score_offset = 90,
        },
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          score_offset = 80,
        },
        snippets = {
          name = "Snippets",
          module = "blink.cmp.sources.snippets",
          score_offset = 85,
          opts = {
            friendly_snippets = true,
            search_paths = { vim.fn.stdpath("config") .. "/snippets" },
          },
        },
        buffer = {
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
          score_offset = 60,
        },
        cmdline = {
          name = "Cmdline",
          module = "blink.cmp.sources.cmdline",
          score_offset = 70,
        },
        omni = {
          name = "Omni",
          module = "blink.cmp.sources.complete_func",
          score_offset = 75,
        },
      },
    },
    cmdline = {
      sources = { "cmdline" },
    },
    fuzzy = {
      sorts = {
        "exact",
        "score",
        "sort_text",
      },
    },
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
  },
}
