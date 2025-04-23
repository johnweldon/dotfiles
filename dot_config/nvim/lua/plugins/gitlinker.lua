require("lib")

return {
  "linrongbin16/gitlinker.nvim",
  cmd = "GitLink",
  opts = function(_, opts)
    print("gitlink options", DebugDump(opts))
  end,
  keys = {
    { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
    { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
  },
}
