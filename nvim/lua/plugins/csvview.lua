return {
	"hat0uma/csvview.nvim",
	ft = "csv",
	config = function()
		vim.api.nvim_create_autocmd({ "FileType" }, {
			pattern = "csv",
			callback = function(args)
				require("csvview").enable(args.buf)
			end,
		})
	end,
	---@module "csvview"
	---@type CsvView.Options
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
}
