-- Using blink.cmp instead of nvim-cmp (see lsp-config.lua)
-- Old nvim-cmp configuration disabled to prevent conflicts
return {
	-- Keeping LuaSnip for snippets support with blink.cmp
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
}
