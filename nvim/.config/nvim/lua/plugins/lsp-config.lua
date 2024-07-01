return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"rust_analyzer",
					"lua_ls",
					"bashls",
					"clangd",
					"cmake",
					"cssls",
					"codeqlls",
					"cypher_ls",
					"dockerls",
					"eslint",
					"glslls",
					"graphql",
					"html",
					"htmx",
					"jsonls",
					"julials",
					"tsserver",
					"jinja_lsp",
					"jqls",
					"autotools_ls",
					"markdown_oxide",
					"pyright",
					"ruff",
					"sqlls",
					"taplo",
					"tailwindcss",
					"terraformls",
					"lemminx",
					"yamlls",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.pyright.setup({ capabilities = capabilities })
			lspconfig.tsserver.setup({ capabilities = capabilities })

			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				-- Server-specific settings. See `:help lspconfig-setup`
				settings = {
					["rust-analyzer"] = {
						workspace = {
							symbol = {
								search = {
									kind = "all_symbols",
								},
							},
						},
					},
				},
			})
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
