local wezterm = require 'wezterm'
local config = {}
local act = wezterm.action

local neofusion_theme = {
  foreground = "#e0d9c7",
  background = "#070f1c",
  cursor_bg = "#e0d9c7",
  cursor_border = "#e0d9c7",
  cursor_fg = "#070f1c",
  selection_bg = "#ea6847",
  selection_fg = "#e0d9c7",
  ansi = {
    "#070f1c", -- Black (Host)
    "#ea6847", -- Red (Syntax string)
    "#ea6847", -- Green (Command)
    "#5db2f8", -- Yellow (Command second)
    "#2f516c", -- Blue (Path)
    "#d943a8", -- Magenta (Syntax var)
    "#86dbf5", -- Cyan (Prompt)
    "#e0d9c7", -- White
  },
  brights = {
    "#2f516c", -- Bright Black
    "#d943a8", -- Bright Red (Command error)
    "#ea6847", -- Bright Green (Exec)
    "#86dbf5", -- Bright Yellow
    "#5db2f8", -- Bright Blue (Folder)
    "#d943a8", -- Bright Magenta
    "#ea6847", -- Bright Cyan
    "#e0d9c7", -- Bright White
  },
}


config.font = wezterm.font 'MesloLGS NF'
-- config.color_scheme = 'GruvboxDark'
-- config.colors = neofusion_theme
-- config.color_scheme = 'Solarized Dark Higher Contrast'
-- config.color_scheme = 'Catppuccin Frappe'
-- config.color_scheme = 'Catppuccin Macchiato'
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'rose-pine'
config.color_scheme = 'Rosé Pine (Gogh)'
-- config.color_scheme = 'rose-pine-moon'
config.font_size = 14
config.enable_scroll_bar = true
config.keys = {
    {
        key = 'h',
        mods = 'WIN',
        action = act.ActivatePaneDirection 'Left', 
    },
    {
        key = 'j',
        mods = 'WIN',
        action = act.ActivatePaneDirection 'Down', 
    },
    {
        key = 'k',
        mods = 'WIN',
        action = act.ActivatePaneDirection 'Up', 
    },
    {
        key = 'l',
        mods = 'WIN',
        action = act.ActivatePaneDirection 'Right', 
    },
    {
        key = 'L',
        mods = 'WIN',
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain'}, 
    },
    {
        key = 'J',
        mods = 'WIN',
        action = act.SplitVertical { domain = 'CurrentPaneDomain'}, 
    },
    {
        key = 'n',
        mods = 'WIN',
        action = act.ActivateTabRelative(1), 
    },
    {
        key = 'N',
        mods = 'WIN',
        action = act.ActivateTabRelative(-1), 
    },
    {
        key = 't',
        mods = 'WIN',
        action = act.SpawnTab 'CurrentPaneDomain', 
    },
    {
        key = 'w',
        mods = 'WIN',
        action = act.CloseCurrentTab{ confirm = false }, 
    },
    {
        key = 'x',
        mods = 'WIN',
        action = act.CloseCurrentTab{ confirm = false }, 
    },
    {
        key = 'T',
        mods = 'WIN',
        action = wezterm.action_callback(function(win, pane)
          local tab, window = pane:move_to_new_tab()
        end),
    },
    {
        key = 'T',
        mods = 'WIN',
        action = wezterm.action_callback(function(win, pane)
          local tab, window = pane:move_to_new_tab()
        end),
    },
    {
        key = 'v',
        mods = 'WIN',
        action = act.ActivateCopyMode,
    },
    {
        key = 'p',
        mods = 'WIN',
        action = act.PasteFrom 'Clipboard',
    },
}

for i = 1, 8 do
  -- CTRL+WIN + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'WIN',
    action = act.ActivateTab(i - 1),
  })
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'WIN | SHIFT',
    action = wezterm.action_callback(function(win, pane)
      local tab, window = pane:move_to_new_tab()
    end),
  })
end

return config
