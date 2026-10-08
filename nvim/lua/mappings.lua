require "nvchad.mappings"

local map = vim.keymap.set
local nomap = vim.keymap.del

-------------------------------------------------------------------------------
-- GENERAL
-------------------------------------------------------------------------------

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })
map("n", "<leader>?", "<cmd>Telescope keymaps<CR>", { desc = "find keymaps" })

-------------------------------------------------------------------------------
-- EDITING & YANK/PASTE BEHAVIOR
-------------------------------------------------------------------------------

map({ "n", "v" }, "c", '"_c', { desc = "change without yanking" })
map({ "n", "v" }, "d", '"_d', { desc = "delete without yanking" })
map("n", "<C-BS>", "d", { desc = "cut (delete and yank)", noremap = true })
nomap("n", "<leader>ds")
map("n", "<leader>d", "d", { desc = "cut (delete and yank)", noremap = true })
map("i", "<C-BS>", "<C-W>", { desc = "delete word backward" })
map("v", "<", "<gv", { desc = "Indent left and keep selection" })
map("v", ">", ">gv", { desc = "Indent right and keep selection" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-------------------------------------------------------------------------------
-- WINDOW MANAGEMENT
-------------------------------------------------------------------------------

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
map({ "n", "v" }, "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-------------------------------------------------------------------------------
-- LEADER GROUPS (LazyVim / AstroNvim Style)
-------------------------------------------------------------------------------
-- NvChad's default mappings are being overridden/reassigned here to fit neat
-- which-key groups.

-- [ <leader>b ] Buffers
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<leader>bc", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })
map("n", "<leader>bf", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })

-- [ <leader>f ] Find / Telescope
-- (Note: NvChad already provides <leader>fw, <leader>fb, <leader>fh, <leader>ff, <leader>fa, etc. Let's add missing/useful ones)
map("n", "<leader>fc", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Find in current buffer" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Find recent (oldfiles)" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Find keymaps" })

-- [ <leader>g ] Git
-- (Move commits and status to the Git menu)
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git branches" })

-- [ <leader>t ] Terminal (moving from NvChad's <leader>h / <leader>v)
nomap("n", "<leader>h")
nomap("n", "<leader>v")
map("n", "<leader>th", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "Terminal horizontal" })
map("n", "<leader>tv", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "Terminal vertical" })
map("n", "<leader>tf", function()
  require("nvchad.term").new { pos = "float" }
end, { desc = "Terminal float" })

-- Sqlit TUI terminal
map("n", "<leader>td", function()
  require("nvchad.term").toggle { pos = "float", id = "sqlit", cmd = "sqlit --theme textual-ansi" }
end, { desc = "Terminal sqlit" })
map("n", "<leader>DD", function()
  require("nvchad.term").toggle { pos = "float", id = "sqlit", cmd = "sqlit --theme textual-ansi" }
end, { desc = "Terminal sqlit (legacy)" })

-- [ <leader>u ] UI Toggles (moving from NvChad's <leader>n, <leader>rn, <leader>th)
nomap("n", "<leader>n")
nomap("n", "<leader>rn")
nomap("n", "<leader>th")
map("n", "<leader>un", "<cmd>set nu!<CR>", { desc = "Toggle line numbers" })
map("n", "<leader>ur", "<cmd>set rnu!<CR>", { desc = "Toggle relative numbers" })
map("n", "<leader>uT", function()
  require("nvchad.themes").open()
end, { desc = "Toggle theme (Telescope)" })
map("n", "<leader>uc", "<cmd>NvCheatsheet<CR>", { desc = "Toggle NvCheatsheet" })

-- [ <leader>c ] Code / LSP (moving NvChad's <leader>fm format)
nomap("n", "<leader>fm")
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format file" })
map("n", "<leader>cd", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-------------------------------------------------------------------------------
-- [ <leader>L ] LSP ACTIONS
-------------------------------------------------------------------------------
-- NvChad sets some LSP mappings dynamically on LspAttach. We override them here
-- to group them all neatly under <leader>L.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local function opts(desc)
      return { buffer = bufnr, desc = "LSP " .. desc }
    end

    -- Unmap NvChad defaults we don't want (using pcall in case they don't exist)
    pcall(vim.keymap.del, "n", "<leader>wa", { buffer = bufnr })
    pcall(vim.keymap.del, "n", "<leader>wr", { buffer = bufnr })
    pcall(vim.keymap.del, "n", "<leader>wl", { buffer = bufnr })
    pcall(vim.keymap.del, "n", "<leader>D", { buffer = bufnr })
    pcall(vim.keymap.del, "n", "<leader>ra", { buffer = bufnr })

    -- Map standard LSP actions to <leader>L
    map("n", "<leader>La", vim.lsp.buf.code_action, opts "Code Action")
    map("n", "<leader>Ld", vim.lsp.buf.definition, opts "Definition")
    map("n", "<leader>LD", vim.lsp.buf.declaration, opts "Declaration")
    map("n", "<leader>Lh", vim.lsp.buf.hover, opts "Hover")
    map("n", "<leader>Li", vim.lsp.buf.implementation, opts "Implementation")
    map("n", "<leader>Lr", require "nvchad.lsp.renamer", opts "Rename")
    map("n", "<leader>LR", vim.lsp.buf.references, opts "References")
    map("n", "<leader>Ls", vim.lsp.buf.signature_help, opts "Signature Help")
    map("n", "<leader>Lt", vim.lsp.buf.type_definition, opts "Type Definition")

    -- Workspace folders
    map("n", "<leader>Lwa", vim.lsp.buf.add_workspace_folder, opts "Add Workspace Folder")
    map("n", "<leader>Lwr", vim.lsp.buf.remove_workspace_folder, opts "Remove Workspace Folder")
    map("n", "<leader>Lwl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts "List Workspace Folders")

    -- Diagnostics
    map("n", "<leader>Le", vim.diagnostic.open_float, opts "Show Diagnostics Float")
  end,
})

-------------------------------------------------------------------------------
-- EXTENDED UI TOGGLES (Inspired by AstroNvimPlus)
-------------------------------------------------------------------------------
-- Autopairs toggle (if plugin is available)
if vim.fn.exists "loaded.nvim-autopairs" == 1 then
  map("n", "<leader>ua", function()
    require("nvim-autopairs").toggle()
  end, { desc = "Toggle autopairs" })
else
  map("n", "<leader>ua", function()
    vim.notify("nvim-autopairs not installed", vim.log.levels.WARN)
  end, { desc = "Toggle autopairs (missing)" })
end

-- Background toggle (toggle dark/light)
map("n", "<leader>ub", function()
  local current = vim.o.background
  vim.o.background = (current == "dark") and "light" or "dark"
  vim.notify("Background set to " .. vim.o.background)
end, { desc = "Toggle background" })

-- Autocompletion (cmp) toggle
if vim.fn.exists "loaded.cmp" == 1 then
  local cmp_enabled = true
  map("n", "<leader>uc", function()
    cmp_enabled = not cmp_enabled
    require("cmp").setup { enabled = cmp_enabled }
    vim.notify("Completion " .. (cmp_enabled and "enabled" or "disabled"))
  end, { desc = "Toggle autocompletion" })
else
  map("n", "<leader>uc", function()
    vim.notify("nvim-cmp not installed", vim.log.levels.WARN)
  end, { desc = "Toggle autocompletion (missing)" })
end

-- Colorizer toggle
if vim.fn.exists ":ColorizerToggle" == 2 then
  map("n", "<leader>uC", ":ColorizerToggle<CR>", { desc = "Toggle colorizer" })
else
  map("n", "<leader>uC", function()
    vim.notify("colorizer.nvim not installed", vim.log.levels.WARN)
  end, { desc = "Toggle colorizer (missing)" })
end

-- Diagnostics toggle (nvim-diagnostic config)
map("n", "<leader>ud", function()
  local d = vim.diagnostic.config()
  local enabled = d.virtual_text ~= false
  vim.diagnostic.config { virtual_text = not enabled, signs = not enabled }
  vim.notify("Diagnostics " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle diagnostics" })

-- Signcolumn toggle
map("n", "<leader>ug", function()
  local sc = vim.wo.signcolumn
  vim.wo.signcolumn = (sc == "yes") and "no" or "yes"
  vim.notify("Signcolumn " .. vim.wo.signcolumn)
end, { desc = "Toggle signcolumn" })

-- Indent setting (prompt for new value)
map("n", "<leader>ui", function()
  local indent = vim.fn.input "Set indent width: "
  local num = tonumber(indent)
  if num then
    vim.opt.shiftwidth = num
    vim.opt.tabstop = num
    vim.notify("Indent set to " .. num)
  else
    vim.notify("Invalid number", vim.log.levels.ERROR)
  end
end, { desc = "Change indent setting" })

-- Statusline toggle
map("n", "<leader>ul", function()
  vim.o.laststatus = (vim.o.laststatus == 2) and 0 or 2
  vim.notify("Statusline " .. ((vim.o.laststatus == 2) and "visible" or "hidden"))
end, { desc = "Toggle statusline" })

-- CodeLens toggle
map("n", "<leader>uL", function()
  vim.lsp.codelens.refresh()
  vim.lsp.codelens.toggle()
  vim.notify "CodeLens toggled"
end, { desc = "Toggle CodeLens" })

-- Line numbering mode (absolute/relative/none)
map("n", "<leader>un", function()
  local mode = vim.wo.number
  if not mode then
    vim.wo.number = true
    vim.wo.relativenumber = false
  elseif vim.wo.relativenumber then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.relativenumber = true
  end
  vim.notify("Numbering: " .. (vim.wo.number and (vim.wo.relativenumber and "relative" or "absolute") or "none"))
end, { desc = "Cycle line numbering" })

-- UI notifications toggle (noice/notify)
map("n", "<leader>uN", function()
  if vim.g.noice_enabled then
    vim.g.noice_enabled = false
    vim.notify "UI notifications disabled"
  else
    vim.g.noice_enabled = true
    vim.notify "UI notifications enabled"
  end
end, { desc = "Toggle UI notifications" })

-- Paste mode toggle
map("n", "<leader>up", function()
  vim.o.paste = not vim.o.paste
  vim.notify("Paste mode " .. (vim.o.paste and "ON" or "OFF"))
end, { desc = "Toggle paste mode" })

-- Spellcheck toggle
map("n", "<leader>us", function()
  vim.o.spell = not vim.o.spell
  vim.notify("Spellcheck " .. (vim.o.spell and "ON" or "OFF"))
end, { desc = "Toggle spellcheck" })

-- Conceal toggle
map("n", "<leader>uS", function()
  vim.wo.conceallevel = (vim.wo.conceallevel == 0) and 2 or 0
  vim.notify("Conceal level " .. vim.wo.conceallevel)
end, { desc = "Toggle conceal" })

-- Tabline toggle
map("n", "<leader>ut", function()
  vim.o.showtabline = (vim.o.showtabline == 2) and 0 or 2
  vim.notify("Tabline " .. ((vim.o.showtabline == 2) and "visible" or "hidden"))
end, { desc = "Toggle tabline" })

-- URL match toggle (vim-matchup)
map("n", "<leader>uu", function()
  require("vim.matchup").enable()
  vim.notify "URL match toggle (placeholder)"
end, { desc = "Toggle URL match" })

-- Wrap toggle
map("n", "<leader>uw", function()
  vim.o.wrap = not vim.o.wrap
  vim.notify("Wrap " .. (vim.o.wrap and "ON" or "OFF"))
end, { desc = "Toggle wrap" })

-- Syntax highlight toggle (buffer-local)
map("n", "<leader>uy", function()
  vim.bo.syntax = (vim.bo.syntax == "") and "on" or ""
  vim.notify("Syntax highlighting " .. (vim.bo.syntax == "" and "OFF" or "ON"))
end, { desc = "Toggle syntax (buffer)" })

-- Foldcolumn toggle
map("n", "<leader>uh", function()
  vim.wo.foldcolumn = (vim.wo.foldcolumn == "0") and "1" or "0"
  vim.notify("Foldcolumn " .. vim.wo.foldcolumn)
end, { desc = "Toggle foldcolumn" })
