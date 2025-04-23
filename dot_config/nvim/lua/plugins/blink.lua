require("lib")

return {
  "saghen/blink.cmp",
  dependencies = { "ribru17/blink-cmp-spell" },
  opts = function(_, opts)
    --print(DebugDump(opts.sources))
    opts.sources.providers["spell"] = {
      name = "Spell",
      module = "blink-cmp-spell",
      opts = {},
    }

    -- default sources:
    --  1: lsp,
    --  2: path,
    --  3: snippets,
    --  4: buffer,
    --  5: lazydev,
    --  6: dadbod,
    opts.sources.per_filetype = { markdown = { "lsp", "path", "snippets", "lazydev", "dadbod", "spell" } }
    opts.sources.min_keyword_length = 4

    local trigger = opts.completion.trigger or {}
    trigger.show_on_keyword = true
    opts.completion.trigger = trigger

    opts.completion.menu.auto_show = false

    local list = opts.completion.list or { selection = {} }
    list.selection = { preselect = true, auto_insert = true }
    opts.completion.list = list
  end,
}
