-- nvim-treesitter on `main` no longer reads `ensure_installed` from opts --
-- its setup() only understands install_dir. Parsers are therefore requested
-- through the new install() API from the treesitter spec in plugins/init.lua.
--
-- Kept deliberately short: every parser compiles on first run. Add what you
-- actually open files in.

return {
  parsers = {
    "bash",
    "css",
    "dockerfile",
    "graphql",
    "hcl",
    "html",
    "javascript",
    "json",
    "json5",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "printf",
    "prisma",
    "query",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "yaml",
  },
}
