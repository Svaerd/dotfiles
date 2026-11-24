return {
  -- TUI file manager opening at the current buffer. NvChad disables netrw,
  -- so this fills the hole. Requires the `yazi` binary.
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
    opts = {
      open_for_directories = false,
      keymaps = { show_help = "<f1>" },
    },
    keys = {
      { "<leader>y", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "yazi" },
      { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "yazi cwd" },
      { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "yazi resume" },
    },
  },

  -- Project-wide find-and-replace with a live results tree. This is the
  -- replacement for :grep plus manual editing.
  --
  -- <leader>p* is free in NvChad (only <leader>pt is used, by Telescope).
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>rr",
        function()
          require("grug-far").open()
        end,
        mode = "n",
        desc = "refactor",
      },
      {
        "<leader>rA",
        function()
          require("grug-far").open { engine = "astgrep" }
        end,
        mode = "n",
        desc = "refactor (ast-grep)",
      },
      {
        "<leader>rw",
        function()
          require("grug-far").open { prefills = { search = vim.fn.expand "<cword>" } }
        end,
        mode = { "n", "v" },
        desc = "refactor word",
      },
      {
        "<leader>rW",
        function()
          require("grug-far").open {
            prefills = { search = vim.fn.expand "<cword>", paths = vim.fn.expand "%" },
          }
        end,
        mode = { "n", "v" },
        desc = "refactor in file",
      },
      {
        "<leader>rf",
        function()
          require("grug-far").open { prefills = { paths = vim.fn.expand "%" } }
        end,
        mode = { "n", "v" },
        desc = "refactor file",
      },
    },
  },

  -- cdir to the project root. Pairs with grug-far so "the project" is
  -- defined consistently.
  {
    "airblade/vim-rooter",
    event = "VeryLazy",
    config = function()
      vim.g.rooter_patterns = {
        "sketch.yaml",
        ".arduino_config.lua",
        "pnpm-workspace.yaml",
        "turbo.json",
        "nx.json",
        "lerna.json",
        "rush.json",
        ".git",
        "Makefile",
      }
      vim.g.rooter_silent_chdir = 1
      vim.g.rooter_resolve_links = 1
    end,
  },

  -- Folds header/mention lines in markdown and other prose.
  {
    "Kenzo-Wada/boundary.nvim",
    ft = { "markdown", "markdown.mdx", "text", "help" },
    config = true,
  },

  -- Folds long Tailwind class lists so the markup stays readable.
  {
    "razak17/tailwind-fold.nvim",
    ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
    opts = { min_chars = 50 },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Named marks with a picker on ' and `. Better than nvChad's
  -- <leader>ma, which lists raw mark positions.
  {
    "chentoast/marks.nvim",
    event = "BufEnter",
    config = true,
  },

  -- TODO/FIX/PERF comment navigation.
  {
    "folke/todo-comments.nvim",
    lazy = false,
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = { alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        WARN = { alt = { "WARNING" } },
        PERF = { alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      },
      highlight = {
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
      },
    },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        mode = "n",
        desc = "next todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        mode = "n",
        desc = "prev todo",
      },
      {
        "<leader>ft",
        "<cmd>TodoTelescope<cr>",
        desc = "todos",
      },
    },
  },

  -- s / S for flash jumps. NvChad binds neither in normal mode.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "flash TS",
      },
    },
    opts = {
      char = { keys = { "f", "F", "t", "T" } },
      highlight = { backdrop = false },
      jump = { autojump = true, nohlsearch = true },
      modes = {
        char = {
          enabled = true,
          keys = { "f", "F", "t", "T", ";" },
          char_actions = function()
            return { [";"] = "next", ["F"] = "left", ["f"] = "right" }
          end,
          highlight = { backdrop = false },
          jump_labels = false,
          multi_line = true,
        },
        search = {
          enabled = true,
          highlight = { backdrop = false },
          jump = { autojump = false },
        },
      },
      prompt = { win_config = { border = "none" } },
      search = { wrap = true },
    },
  },

  -- Which-key already carries NvChad's entries, so only the new groups
  -- from this config are registered here.
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    opts = {
      spec = {
        -- Main groups
        { "<leader>a", group = "ai" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find/telescope" },
        { "<leader>g", group = "git" },
        { "<leader>L", group = "lsp actions" },
        { "<leader>o", group = "opencode" },
        { "<leader>p", group = "project" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui/toggles" },
        { "<leader>y", group = "yazi" },
        { "<leader>pp", group = "npm" },
        { "<leader>r", group = "refactor" },

        -- Specific mappings defined elsewhere
        { "<leader>cs", desc = "snippets" },
        { "<leader>cu", desc = "toggle symbol usage" },
        { "ga", desc = "align" },
        { "gA", desc = "align (preview)" },
        { "<C-a>", desc = "increment" },
        { "<C-x>", desc = "decrement" },
        { "<leader>l", desc = "lint buffer" },

        -- Existing Git mappings
        { "<leader>gD", desc = "diffview" },
        { "<leader>gd", desc = "file history" },
        { "<leader>gS", desc = "git status" },
        { "<leader>gL", desc = "yank git url" },

        { "<leader>ft", desc = "todo comments" },
        { "<leader>D", desc = "sqlit" },
        { "<leader>cv", desc = "tailwind values" },
        { "<leader>?", desc = "find keymaps" },
      },
    },
  },

  -- package.json version virtual text + install/update/delete.
  --
  -- EcoVim hung these off <leader>n, but NvChad owns <leader>n for toggling
  -- line numbers -- that would make every <leader>n* press wait on a
  -- timeout. Moved to <leader>pp.
  {
    "vuki656/package-info.nvim",
    event = "BufEnter package.json",
    opts = {
      autostart = true,
      hide_up_to_date = true,
      hide_unstable_versions = true,
      package_manager = "npm",
      icons = { enable = true },
    },
    keys = {
      {
        "<leader>ppu",
        function()
          require("package-info").update()
        end,
        mode = { "n", "x" },
        desc = "update package",
      },
      {
        "<leader>ppi",
        function()
          require("package-info").install()
        end,
        mode = { "n", "x" },
        desc = "install package",
      },
      {
        "<leader>ppd",
        function()
          require("package-info").delete()
        end,
        mode = { "n", "x" },
        desc = "delete package",
      },
      {
        "<leader>pph",
        function()
          require("package-info").hide()
        end,
        mode = { "n", "x" },
        desc = "hide",
      },
      {
        "<leader>pps",
        function()
          require("package-info").show()
        end,
        mode = { "n", "x" },
        desc = "show",
      },
    },
  },

  {
    "MaximilianLloyd/tw-values.nvim",
    keys = {
      { "<leader>cv", "<cmd>TWValues<cr>", desc = "tailwind value" },
    },
    opts = { show_unknown_classes = true },
  },
  {
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    cond = vim.g.neovide == nil,
    opts = function(_, opts)
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs { "Up", "Down" } do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "grug-far",
        callback = function()
          vim.b.minianimate_disable = true
        end,
      })

      -- schedule setting the mapping to override the default mapping from `keymaps.lua`
      -- seems `keymaps.lua` is the last event to execute on `VeryLazy` and it overwrites it
      vim.schedule(function()
        vim.keymap.set("n", "<leader>ua", function()
          vim.g.minianimate_disable = not vim.g.minianimate_disable
          vim.notify("mini.animate " .. (vim.g.minianimate_disable and "off" or "on"), vim.log.levels.INFO)
        end, { desc = "Toggle mini.animate" })
      end)

      local animate = require "mini.animate"
      return vim.tbl_deep_extend("force", opts, {
        resize = {
          timing = animate.gen_timing.linear { duration = 50, unit = "total" },
        },
        scroll = {
          timing = animate.gen_timing.linear { duration = 150, unit = "total" },
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
      })
    end,
  },
}
