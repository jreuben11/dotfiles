return {
  'akinsho/toggleterm.nvim', 
  version = "*", 
  config = function()
    require("toggleterm").setup()
    
    local Terminal = require('toggleterm.terminal').Terminal
    local claude_code = Terminal:new({
      cmd = "claude-code",
      direction = "float",
      float_opts = {
        border = "curved",
        width = 120,
        height = 40,
      },
      close_on_exit = true,
    })

    function _claude_code_toggle()
      claude_code:toggle()
    end

    vim.api.nvim_set_keymap("n", "<leader>C", "<cmd>lua _claude_code_toggle()<CR>", 
      { noremap = true, silent = true, desc = "Open Claude Code" })
  end
}
