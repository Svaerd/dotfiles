return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-emoji",
		},
		---@param opts cmp.ConfigSchema
		opts = function(_, opts)
			local cmp = require("cmp")
			local compare = require("cmp.config.compare")

			opts.sorting = {
				priority_weight = 2,
				comparators = {
					compare.offset,
					compare.exact,
					function(entry1, entry2)
						local kind1 = entry1:get_kind()
						local kind2 = entry2:get_kind()
						if kind1 ~= kind2 then
							if kind1 == cmp.lsp.CompletionItemKind.Snippet then
								return true
							end
							if kind2 == cmp.lsp.CompletionItemKind.Snippet then
								return false
							end
						end
					end,
					function(entry1, entry2)
						local src1 = entry1.source.name or ""
						local src2 = entry2.source.name or ""
						local is_vscode1 = src1 == "vscode" or src1 == "luasnip"
						local is_vscode2 = src2 == "vscode" or src2 == "luasnip"
						if is_vscode1 ~= is_vscode2 then
							return is_vscode1
						end
					end,
					compare.score,
					compare.recently_used,
					compare.locality,
					compare.kind,
					compare.sort_text,
					compare.length,
					compare.order,
				},
			}
		end,
	},
}
