return {
  -- Diff review UI: file tree, staged/unstaged tabs, per-hunk stage/revert,
  -- commit from the buffer. NvChad only gives you gitsigns plus Telescope's
  -- git pickers, which cannot stage or commit anything.
  --
  -- <leader>g* is free in NvChad apart from <leader>gt (Telescope git status).
  {
    "dlyongemallo/diffview.nvim",
    lazy = false,
    config = function()
      require("diffview").setup()
    end,
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "diffview" },
      { "<leader>gd", "<cmd>DiffviewFileHistory %<cr>", desc = "file history" },
      { "<leader>gS", "<cmd>DiffviewStatus<cr>", desc = "git status" },
      { "<leader>gb", "<cmd>DiffviewToggleFiles<cr>", desc = "toggle files" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "close diffview" },
    },
  },

  -- Yank a git:// permalink for the current line or selection.
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    config = true,
    keys = {
      { "<leader>gL", "<cmd>GitLink<cr>", mode = "x", desc = "yank git url" },
    },
  },

  -- Lazygit in a floating window (<leader>lg, same as old LazyVim).
  -- Needs the lazygit binary on PATH.
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "lazygit" },
    },
  },
}
