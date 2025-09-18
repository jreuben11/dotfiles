return {
  "folke/snacks.nvim",
  opts = {
    -- Ensure notifier is properly enabled
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    image = {
      -- Enable image support
      enabled = true,
      -- Configure for WezTerm (since Zellij doesn't support graphics protocol)
      backend = "wezterm",
      -- Override terminal detection since we're in Zellij
      integrations = {
        -- Disable default terminal detection
        auto = false,
        -- Force WezTerm backend
        wezterm = true,
        kitty = false,
      },
    },
  },
}