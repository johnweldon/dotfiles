local lib = require("lib")
local debug = lib.create_logger("gitlinker")

return {
  "linrongbin16/gitlinker.nvim",
  cmd = "GitLink",
  opts = function(_, opts)
    debug.log("Gitlinker options", opts)
    return opts
  end,
  keys = {
    { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
    { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
  },
}
