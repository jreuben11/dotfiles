return {
  "swaits/zellij-nav.nvim",
  lazy = true,
  event = "VeryLazy",
  keys = {
    { "<C-h>", "<cmd>ZellijNavigateLeft<cr>",  desc = "Navigate left (nvim/zellij)" },
    { "<C-j>", "<cmd>ZellijNavigateDown<cr>",  desc = "Navigate down (nvim/zellij)" },
    { "<C-k>", "<cmd>ZellijNavigateUp<cr>",    desc = "Navigate up (nvim/zellij)" },
    { "<C-l>", "<cmd>ZellijNavigateRight<cr>", desc = "Navigate right (nvim/zellij)" },
  },
  opts = {},
}
