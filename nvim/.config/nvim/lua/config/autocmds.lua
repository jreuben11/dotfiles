-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command("ClearRegs", function()
    for _, r in ipairs(vim.split("abcdefghijklmnopqrstuvwxyz0123456789\"-+*/", "")) do
        pcall(function() vim.fn.setreg(r, "") end)
    end
    vim.notify("All registers cleared", vim.log.levels.INFO)
end, { desc = "Clear all registers" })
