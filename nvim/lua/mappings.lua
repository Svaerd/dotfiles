require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Ported from the old LazyVim config (~/.cache/dotfiles/nvim.old).
-- Delete/change into the blackhole register so nothing gets yanked.
map({ "n", "v" }, "c", '"_c', { desc = "change without yanking" })
map({ "n", "v" }, "d", '"_d', { desc = "delete without yanking" })

-- Raw <C-BS> -> raw d in normal mode: noremap so the d-map above is
-- bypassed and d fires as the default delete, which yanks (a real cut).
map("n", "<C-BS>", "d", { desc = "cut (delete and yank)", noremap = true })

-- Old config toggled the tree with <leader>e; NvChad's <leader>e only
-- focuses it. Uses NvimTreeToggle directly -- a <C-n> rhs with noremap
-- would fire the raw key (cursor down), since noremap skips mapping lookup.
map({ "n", "v" }, "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- Searchable keymap list. NvChad's own <leader>ch cheatsheet cannot be
-- searched: it renders each mapping as a virt_text overlay on blank buffer
-- lines, so there is no buffer text for `/` to match.
map("n", "<leader>?", "<cmd>Telescope keymaps<CR>", { desc = "find keymaps" })

-- Enable control backspace while in insert/append mode.
map("i", "<C-BS>", "<C-W>", { desc = "delete word backward" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- sqlit is a standalone TUI (uv/python app), not a Neovim plugin, so there
-- is no plugin spec for it -- it just gets spawned in a terminal.
--
-- <leader>DD rather than <leader>D: NvChad maps <leader>D to
-- vim.lsp.buf.type_definition on LspAttach (buffer-local), which would win.
map("n", "<leader>DD", function()
  require("nvchad.term").toggle { pos = "float", id = "sqlit", cmd = "sqlit --theme textual-ansi" }
end, { desc = "sqlit" })
