return {
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		-- Add additional parsers to LazyVim's default list
		vim.list_extend(opts.ensure_installed, {
			"rust",
			"python",
			"c",
			"lua",
			"vim",
			"vimdoc",
			"javascript",
			"html",
			"bash",
			"cmake",
			"cpp",
			"css",
			"cuda",
			"diff",
			"dockerfile",
			"dot",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"glsl",
			"gnuplot",
			"graphql",
			"helm",
			"hlsl",
			"ini",
			"jq",
			"json",
			"json5",
			"julia",
			"latex",
			"llvm",
			"markdown",
			-- "make", -- Temporarily remove make parser due to corruption
			"mermaid",
			"ninja",
			"nix",
			"objdump",
			"promql",
			"proto",
			"sparql",
			"sql",
			"terraform",
			"tmux",
			"toml",
			"typescript",
			"xml",
			"yaml",
		})

		-- Ensure Tree-sitter highlighting is enabled for markdown files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
