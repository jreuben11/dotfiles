return {
	{
		"mason-org/mason.nvim",
		version = ">=2.0",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
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
					-- "julials",  -- Removed: causing startup errors
					"ts_ls",
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
			-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local capabilities = require("blink.cmp").get_lsp_capabilities() -- recomended by grok
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({ capabilities = capabilities })
			lspconfig.pyright.setup({ capabilities = capabilities })
			lspconfig.tsserver.setup({ capabilities = capabilities })

			-- lspconfig.rust_analyzer.setup({
			-- 	capabilities = capabilities,
			-- 	-- Server-specific settings. See `:help lspconfig-setup`
			-- 	settings = {
			-- 		["rust-analyzer"] = {
			-- 			workspace = {
			-- 				symbol = {
			-- 					search = {
			-- 						kind = "all_symbols",
			-- 					},
			-- 				},
			-- 			},
			-- 		},
			-- 	},
			-- })
			local map = function(keys, fn, desc)
				vim.keymap.set("n", keys, fn, { desc = "LSP: " .. desc })
			end
			map("K",          vim.lsp.buf.hover,            "Hover docs")
			map("gd",         vim.lsp.buf.definition,       "Go to definition")
			map("gD",         vim.lsp.buf.declaration,      "Go to declaration")
			map("gr",         vim.lsp.buf.references,       "Go to references")
			map("gI",         vim.lsp.buf.implementation,   "Go to implementation")
			map("gy",         vim.lsp.buf.type_definition,  "Go to type definition")
			map("<leader>cr", vim.lsp.buf.rename,           "Rename symbol")
			map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format file")
			map("[d",         vim.diagnostic.goto_prev,     "Prev diagnostic")
			map("]d",         vim.diagnostic.goto_next,     "Next diagnostic")
			map("<leader>cd", vim.diagnostic.open_float,    "Show diagnostic")
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
		end,
	},
}
