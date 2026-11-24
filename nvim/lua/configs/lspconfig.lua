-- Installed and auto-started by mason-lspconfig. Ported from EcoVim's
-- lsp.lua, with tsgo swapped for ts_ls: tsgo is not a mason-lspconfig
-- package on every registry revision, and ts_ls is the stable choice.
--
-- `copilot` is excluded so it never auto-starts as a plain LSP.
local servers = {
  "bashls",
  "biome",
  "clangd",
  "cssls",
  "denols",
  "dockerls",
  "eslint",
  "graphql",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "oxlint",
  "prismals",
  "pyright",
  "sqlls",
  "tailwindcss",
  "terraformls",
  "tflint",
  "ts_ls",
  "vue_ls",
  "yamlls",
}

local M = { servers = servers }

function M.setup()
  -- nvChad's defaults(): diagnostic config, on_attach keymaps (gd, gD,
  -- <leader>ra, ...), lua_ls workspace library, semanticTokens opt-out.
  require("nvchad.configs.lspconfig").defaults()

  -- nvChad advertises a static capability table. blink advertises strictly
  -- more, which improves server-side completions. vim.lsp.config merges, so
  -- on_init and the rest of nvChad's defaults survive this call.
  vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
  vim.lsp.config("cssls", {
    settings = {
      css = { validate = true, lint = { unknownAtRules = "ignore" } },
      scss = { validate = true, lint = { unknownAtRules = "ignore" } },
      less = { validate = true, lint = { unknownAtRules = "ignore" } },
    },
  })
  vim.lsp.config("html", {
    settings = {
      html = { validate = true },
      css = { validate = false },
    },
  })

  -- lua_ls: let stylua own formatting, and let lazydev manage the workspace
  -- library instead of hardcoding nvChad's paths.
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        format = { enable = false },
        completion = { callSnippet = "Replace" },
      },
    },
  })
end

return M
