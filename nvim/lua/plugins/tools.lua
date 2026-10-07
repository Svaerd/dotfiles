return {
  -- External linters writing into the same vim.diagnostic namespace as the
  -- LSP, so squiggles come from one place. eslint/oxlint catch what ts_ls
  -- does not, and vice versa.
  --
  -- Mason picks these up automatically through NvChad's mason bridge, which
  -- scans lint.linters_by_ft.
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "pylint" },
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        hcl = { "tflint" },
      }
    end,
    keys = {
      { "<leader>l", function() require("lint").try_lint() end, mode = "n", desc = "lint buffer" },
    },
  },

  -- LSP progress bar: "LSP · Loading tsgo..." while servers start, plus
  -- code-action and rename states. NvChad gives no feedback here at all.
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = { suppress_on_insert = false },
    },
  },

  -- Annotates symbols with reference/implementation counts so you can spot
  -- dead code before deleting it.
  {
    "Wansmer/symbol-usage.nvim",
    event = "LspAttach",
    config = function()
      local SymbolKind = vim.lsp.protocol.SymbolKind

      local function text_format(symbol)
        local fragments = {}

        if symbol.references then
          local usage = symbol.references <= 1 and "usage" or "usages"
          local num = symbol.references == 0 and "no" or symbol.references
          fragments[#fragments + 1] = ("%s %s"):format(num, usage)
        end

        if symbol.definition then
          fragments[#fragments + 1] = symbol.definition .. " defs"
        end

        if symbol.implementation then
          fragments[#fragments + 1] = symbol.implementation .. " impls"
        end

        local stacked = symbol.stacked_count > 0 and (" | +%s"):format(symbol.stacked_count) or ""

        return table.concat(fragments, ", ") .. stacked
      end

      require("symbol-usage").setup {
        hl = { link = "Comment" },
        vt_position = "above",
        kinds = {
          SymbolKind.Function,
          SymbolKind.Method,
          SymbolKind.Class,
          SymbolKind.Interface,
          SymbolKind.Module,
        },
        references = { enabled = true, include_declaration = false },
        definition = { enabled = false },
        implementation = { enabled = true },
        text_format = text_format,
        request_pending_text = false,
      }
    end,
    keys = {
      {
        "<leader>cu",
        function() require("symbol-usage").toggle() end,
        desc = "toggle symbol usage",
      },
    },
  },

  -- Encrypt/decrypt with SOPS. Only useful if you handle secrets.
  {
    "lucidph3nx/nvim-sops",
    cmd = { "SopsEncrypt", "SopsDecrypt" },
  },

  -- sqlit is a standalone TUI (a uv/python app), not a Neovim plugin, so it is
  -- not declared here -- see the <leader>D mapping in lua/mappings.lua, which
  -- just spawns it in a floating terminal.
}
