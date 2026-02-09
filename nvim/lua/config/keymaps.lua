-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- map <control + backspace> to "delete word"
vim.api.nvim_set_keymap("i", "<C-BS>", "<C-W>", { noremap = true })

vim.keymap.set({ "n", "v" }, "c", '"_c', { noremap = true })

vim.keymap.set({ "n", "v" }, "d", '"_d', { noremap = true })
vim.keymap.set("n", "<leader>r", "d", { noremap = true })

