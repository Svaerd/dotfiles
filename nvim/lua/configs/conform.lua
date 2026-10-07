-- nvChad's default (lua = stylua) plus EcoVim's formatter table. Mason picks
-- these up automatically through nvChad's mason bridge, which scans
-- conform.list_all_formatters().
return {
  formatters_by_ft = {
    css = { "prettierd", "prettier" },
    graphql = { "prettierd", "prettier" },
    hcl = { "hclfmt" },
    html = { "prettierd", "prettier" },
    javascript = { "biome", "prettierd", "prettier" },
    javascriptreact = { "biome", "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    jsonc = { "prettierd", "prettier" },
    lua = { "stylua" },
    markdown = { "prettierd", "prettier" },
    python = { "isort", "black" },
    sql = { "sql-formatter" },
    svelte = { "prettierd", "prettier" },
    typescript = { "biome", "prettierd", "prettier" },
    typescriptreact = { "biome", "prettierd", "prettier" },
    xml = { "xmlformatter" },
    yaml = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}
