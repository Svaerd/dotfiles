return {
  -- Quote/bracket wrapping. NvChad has no equivalent; Vim's built-in s verb
  -- only works around objects you can already select.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },

  -- Case conversion on gu-prefixed keys (guk -> kebab-case, guc -> camelCase).
  -- Works as an operator over motions and in visual mode.
  {
    "johmsalas/text-case.nvim",
    cmd = { "TextCaseOpenTelescope", "Subs" },
    config = function()
      require("textcase").setup {
        default_keymappings_enabled = true,
        -- Default is "ga", which mini.align now owns.
        prefix = "gu",
        enabled_methods = {
          "to_upper_case",
          "to_lower_case",
          "to_camel_case",
          "to_snake_case",
          "to_dash_case",
          "to_title_dash_case",
          "to_constant_case",
          "to_dot_case",
          "to_phrase_case",
          "to_pascal_case",
          "to_title_case",
          "to_path_case",
        },
      }

      -- The defaults cover c/s/d/p/u/l. These fill in the cases EcoVim
      -- mapped by hand: guk = kebab (mnemonic), gud = dot.case,
      -- gut = Title Case, gu/ = path/case, gu<space> = phrase case.
      local map = vim.keymap.set

      local function extra(suffix, case, desc)
        map("n", "gu" .. suffix, function()
          require("textcase").current_word(case)
        end, { desc = desc })
        map("n", "gu" .. suffix:upper(), function()
          require("textcase").current_word(case)
        end, { desc = desc })
        map("n", "guo" .. suffix, function()
          require("textcase").operator(case)
        end, { desc = desc })
        map("x", "gu" .. suffix, function()
          require("textcase").operator(case)
        end, { desc = desc })
      end

      extra("k", "to_dash_case", "kebab-case")
      extra("d", "to_dot_case", "dot.case")
      extra("t", "to_title_case", "Title Case")
      extra("/", "to_path_case", "path/case")
      extra("<space>", "to_phrase_case", "phrase case")
    end,
  },

  -- dial owns <C-a>/<C-x>. Chosen over EcoVim's switch.vim (speeddating)
  -- because tailwindcss-dial steps through the real Tailwind scale:
  -- p-2 -> p-3 -> p-4 instead of jumping raw numbers.
  --
  -- dial.nvim has no setup() and no lua/dial/init.lua, so `config = true`
  -- fails with "module 'dial' not found". Configuration goes through
  -- dial.config.augends:register_group, and the plugin only ships
  -- <Plug> mappings -- the <C-a>/<C-x> bindings below are ours to make.
  {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<C-a>",
        function()
          require("dial.map").inc_normal()
        end,
        mode = { "n", "x" },
        desc = "dial increment",
      },
      {
        "<C-x>",
        function()
          require("dial.map").dec_normal()
        end,
        mode = { "n", "x" },
        desc = "dial decrement",
      },
      {
        "g<C-a>",
        function()
          require("dial.map").inc_gnormal()
        end,
        mode = { "n", "x" },
        desc = "dial +10",
      },
      {
        "g<C-x>",
        function()
          require("dial.map").dec_gnormal()
        end,
        mode = { "n", "x" },
        desc = "dial -10",
      },
    },
    config = function()
      local augend = require "dial.augend"

      require("dial.config").augends:register_group {
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.new { pattern = "%Y/%m/%d", default_kind = "day" },
        },
      }
    end,
  },

  -- Left unfiletyped on purpose: tailwindcss-dial only augments the default
  -- group when no `ft`/`group` is set, which is what makes p-2 -> p-3 work
  -- everywhere rather than just in markup files.
  {
    "ruicsh/tailwindcss-dial.nvim",
    dependencies = "monaqa/dial.nvim",
    opts = {},
  },

  -- So `.` repeats a dial increment. Replaces switch.vim, which existed
  -- purely to pair with it.
  { "tpope/vim-repeat", lazy = false },

  -- Build a print/log statement around the thing under cursor.
  {
    "rareitems/printer.nvim",
    ft = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    opts = {
      keymap = "gp",
      behavior = "yank",
      formatters = {
        lua = function(inside, variable)
          return string.format('print("%s: " .. %s)', inside, variable)
        end,
        typescriptreact = function(inside, variable)
          return string.format("console.log('%s: ', %s);", inside, variable)
        end,
      },
      add_to_inside = function(text)
        return string.format("[%s:%s] %s", vim.fn.expand "%:h", vim.fn.line ".", text)
      end,
    },
  },

  -- Snippet manager for your own snippets, stored as plain files in
  -- config/snippets. Distinct from friendly-snippets, which nvChad already
  -- bundles: scissors is for snippets you write once and reuse everywhere.
  {
    "chrisgrieser/nvim-scissors",
    cmd = "Scissors",
    opts = {
      snippetDir = vim.fn.stdpath "config" .. "/snippets",
    },
    keys = {
      { "<leader>cs", "<cmd>Scissors<cr>", desc = "snippet" },
    },
  },

  -- Writes on focus-out and insert-leave. Neither nvChad nor EcoVim had
  -- this.
  {
    "Pocco81/auto-save.nvim",
    cmd = { "AutoSaveStart", "AutoSaveStop", "AutoSaveToggle" },
    init = function()
      if vim.fn.has "nvim-0.10" ~= 1 then
        vim.g.auto_save_delay = 1000
        vim.g.auto_save_ignore_confirm = true
        vim.g.auto_save_events = { "InsertLeave", "TextChanged" }
      else
        vim.g.auto_save = {
          enabled = true,
          execution_message = false,
          delay = 1000,
          pattern = { "*.json", "*.lua", "*.md", "*.txt" },
          events = { "InsertLeave", "TextChanged" },
          condition = function(inserted)
            return true
          end,
        }
      end
    end,
  },

  -- Text objects: if/af around a function, ic/ac inside a class.
  -- NvChad ships no treesitter textobjects at all.
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup()
    end,
  },

  -- Aligns assignments/comments/fields across a block. Defaults to ga / gA,
  -- which collide with nothing here, so the stock mappings are kept.
  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    version = "*",
    opts = {},
  },

  -- Generate a carbon.now.sh image of the code block and insert it as
  -- markdown. Needs a C toolchain (build = "make").
  {
    "mistricky/codesnap.nvim",
    build = "make",
    cmd = { "CodeSnap", "CodeSnapHighlight" },
    opts = { watermark = "" },
  },

  -- Undo-tree sidebar on U. The mapping lives in `keys` rather than a
  -- config block: defaults.lazy = true means a spec with no event/cmd/keys/ft
  -- gets no trigger at all, so config never ran and U stayed unmapped.
  {
    "mbbill/undotree",
    keys = {
      { "U", "<cmd>UndotreeToggle<CR>", desc = "toggle undotree", noremap = true, silent = true },
    },
  },

  -- Spreadsheet grid for .csv. All keymaps are buffer-local.
  {
    "hat0uma/csvview.nvim",
    ft = "csv",
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    config = function(_, opts)
      require("csvview").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "csv",
        callback = function(args)
          require("csvview").enable(args.buf)
        end,
      })
    end,
  },
}
