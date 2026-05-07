-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Normal/visual mode C-h/j/k/l handled by zellij-nav.nvim (navigates nvim splits AND zellij panes)
-- Terminal mode: Alt keys escape terminal and move to nvim window (fallback when not using zellij-nav)
vim.keymap.set("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
vim.keymap.set("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Go to down window" })
vim.keymap.set("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Go to up window" })
vim.keymap.set("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Enter Normal mode" })

-- Enable mouse support in terminal mode
vim.keymap.set("t", "<ScrollWheelUp>", "<ScrollWheelUp>", { desc = "Scroll up in terminal" })
vim.keymap.set("t", "<ScrollWheelDown>", "<ScrollWheelDown>", { desc = "Scroll down in terminal" })
