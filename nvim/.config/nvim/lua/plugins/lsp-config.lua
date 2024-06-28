return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup(
                {
                    ensure_installed = {
                        "rust-analyzer",
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
                    }
                }
            )
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require('lspconfig')
            lspconfig.lua_ls.setup({})
            lspconfig.pyright.setup({})
            lspconfig.tsserver.setup({})

            lspconfig.rust_analyzer.setup {
              -- Server-specific settings. See `:help lspconfig-setup`
              settings = {
                ['rust-analyzer'] = {},
              },
            }
        end
    }
}
