return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	}, -- neotree https://github.com/nvim-neo-tree/neo-tree.nvim
	keys = {
		{
			"<leader>sO",
			"<cmd>Neotree document_symbols<cr>",
			desc = "Document Symbols (Neo-tree)",
		},
	},
}
