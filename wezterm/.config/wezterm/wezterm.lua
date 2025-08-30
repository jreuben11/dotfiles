-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Set zsh as the default shell without login shell behavior
config.default_prog = { "/usr/bin/zsh" }
config.set_environment_variables = {
  SHELL = "/usr/bin/zsh",
}

-- For example, changing the color scheme:
config.color_scheme = "Tokyo Night"
config.window_background_image = wezterm.home_dir .. "cyberpunk-80s-vibe.jpg"
-- config.window_background_opacity = 0.7
-- Maximize window on startup (only once)
wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)
-- and finally, return the configuration to wezterm
return config
