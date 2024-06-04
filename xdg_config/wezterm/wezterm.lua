-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Set background to same color as neovim
config.colors = {}
config.colors.background = "#111111"

config.font = wezterm.font_with_fallback({
	"Berkeley Mono",
	"JetBrains Mono",
	"nonicons",
})

-- Tmux style keybindings
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	--   -- splitting
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "|",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	-- Tab switching
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action({ ActivateTabRelative = 1 }),
	},
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action({ ActivateTabRelative = -1 }),
	},
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action({ ActivatePaneDirection = "Right" }),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action({ ActivatePaneDirection = "Down" }),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "RightArrow",
		mods = "CTRL",
		action = wezterm.action({ SendString = "\x1bf" }),
	},
	{
		key = "LeftArrow",
		mods = "CTRL",
		action = wezterm.action({ SendString = "\x1bb" }),
	},
}

-- default is true, has more "native" look
config.use_fancy_tab_bar = false

-- I don't like putting anything at the ege if I can help it.
config.enable_scroll_bar = false
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- wezterm.on("format-tab-title", function(tab)
-- 	return {
-- 		{ Text = string.format(" %d: wezterm ", tab.tab_index + 1) },
-- 	}
-- end)

wezterm.on("update-right-status", function(pane)
	local proc_name = pane:get_current_process_name()
	local tab_title = string.format(" %d: %s ", pane.index + 1, proc_name)
	return {
		{ Text = tab_title },
	}
end)

config.send_composed_key_when_left_alt_is_pressed = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.freetype_load_target = "HorizontalLcd"
-- and finally, return the configuration to wezterm
return config
