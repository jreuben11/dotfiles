return {
  "coder/claudecode.nvim",
  config = function()
    require("claudecode").setup({
      -- Port for the WebSocket server (default: 7863)
      port = 7863,
      -- Auto-start the server when Neovim starts (default: false)
      auto_start = true,
      -- Show notifications when Claude Code connects/disconnects
      notifications = true,
      -- Automatically reload buffers when files are modified by Claude
      auto_reload = true,
    })
  end,
  keys = {
    {
      "<leader>cc",
      function()
        require("claudecode").toggle()
      end,
      desc = "Toggle Claude Code server",
    },
    {
      "<leader>cs",
      function()
        require("claudecode").start()
      end,
      desc = "Start Claude Code server",
    },
    {
      "<leader>cq",
      function()
        require("claudecode").stop()
      end,
      desc = "Stop Claude Code server",
    },
  },
}