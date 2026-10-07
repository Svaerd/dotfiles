return {
  -- ── Completion: nvim-cmp -> blink.cmp ─────────────────────────────────
  -- siduck's official bridge (NvChad/NvChad#3244). It disables
  -- hrsh7th/nvim-cmp and pulls in saghen/blink.cmp with LuaSnip,
  -- friendly-snippets and nvim-autopairs as dependencies.
  --
  -- Requires base46 v3.0 for the compiled blink theme. Already satisfied;
  -- if you ever see "cannot open .../base46/blink", delete the base46
  -- entry from lazy-lock.json *and* ~/.local/share/<appname>/lazy/base46.
  { import = "nvchad.blink.lazyspec" },

  -- Avante calls cmp.register_source() during setup. blink.compat intercepts
  -- those registrations and forwards them to blink, which is what makes the
  -- avante_* providers in configs/blink.lua resolve. Flip debug = true if
  -- @-completion stops working.
  {
    "saghen/blink.compat",
    opts = { impersonate_nvim_cmp = true, debug = false },
  },

  -- nvChad's blink keymap is left alone on purpose: <Tab> is
  -- select_next -> snippet_forward -> fallback, which reproduces the
  -- nvim-cmp "tab cycles through items" behaviour you had. The super-tab
  -- preset would make <Tab> accept instead, so it is not used here.
  {
    "saghen/blink.cmp",
    opts = require "configs.blink",
  },

  -- ── Formatting ────────────────────────────────────────────────────────
  -- Replaces the starter's bare { lua = { stylua } } table.
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = require "configs.conform",
  },

  -- ── LSP ───────────────────────────────────────────────────────────────
  -- Overrides NvChad's own nvim-lspconfig spec, which only enabled
  -- lua_ls/html/cssls.
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function()
      require("configs.lspconfig").setup()
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = "User FilePost",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = require("configs.lspconfig").servers,
        automatic_enable = { exclude = { "copilot" } },
      }
    end,
  },

  -- ── Treesitter ────────────────────────────────────────────────────────
  -- nvim-treesitter on `main` dropped the old setup() keys, so nvChad's
  -- ensure_installed table (and EcoVim's, which additionally errored on the
  -- removed nvim-treesitter.configs module) is a no-op. Parsers are
  -- requested explicitly here instead.
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup()
      vim.schedule(function()
        require("nvim-treesitter").install(require("configs.treesitter").parsers)
      end)
    end,
  },

  -- ── UI: notifications + cmdline ───────────────────────────────────────
  -- Floating notification backend for vim.notify. noice routes messages
  -- through it; :Notifications opens history.
  {
    "rcarriga/nvim-notify",
    opts = function()
      return {
        stages = "fade",
        timeout = 3000,
        render = "default",
        top_down = true,
      }
    end,
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  -- Popup cmdline (replaces the plain : echo line), message history in a
  -- split, and popupmenu for wildmenu. Progress/signature stay with
  -- fidget.nvim (tools.lua) and NvChad's lsp.signature, so noice's versions
  -- of those are off to avoid duplicates.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = { enabled = true, view = "cmdline_popup" },
      messages = { enabled = true },
      popupmenu = { enabled = true },
      lsp = {
        progress = { enabled = false },
        signature = { enabled = false },
      },
    },
    keys = {
      {
        "<leader>Nl",
        function() require("noice").cmd("last") end,
        desc = "noice: last notification",
      },
      {
        "<leader>Nh",
        function() require("noice").cmd("history") end,
        desc = "noice: notification history",
      },
    },
  },
}
