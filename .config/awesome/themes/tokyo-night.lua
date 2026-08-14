local gfs = require("gears.filesystem")

local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

-- Tokyo Night Palette
local tn = {
    bg        = "#1a1b26",
    bg_dark   = "#16161e",
    bg_highlight = "#292e42",
    terminal_black = "#414868",
    fg        = "#c0caf5",
    fg_dark   = "#a9b1d6",
    blue      = "#7aa2f7",
    cyan      = "#7dcfff",
    blue7     = "#3d59a1",
    magenta   = "#bb9af7",
    purple    = "#9d7cd8",
    orange    = "#ff9e64",
    yellow    = "#e0af68",
    green     = "#9ece6a",
    teal      = "#1abc9c",
    red       = "#f7768e",
}

theme.font                 = "MesloLGS Nerd Font 12"
theme.taglist_font         = "MesloLGS Nerd Font Bold 12"
theme.wibar_height         = 34
theme.systray_icon_spacing = 8
theme.useless_gap          = 6
theme.border_width         = 2
theme.wallpaper            = gfs.get_configuration_dir() .. "wallpaper.jpg"
theme.tasklist_plain_task_name = true

-- Colors
theme.bg_normal     = tn.bg
theme.bg_focus      = tn.bg_highlight
theme.bg_urgent     = tn.red
theme.bg_minimize   = tn.bg_dark
theme.bg_systray    = tn.bg_dark

theme.fg_normal     = tn.fg_dark
theme.fg_focus      = tn.cyan
theme.fg_urgent     = tn.bg
theme.fg_minimize   = tn.terminal_black

theme.border_normal = tn.bg_highlight
theme.border_focus  = tn.blue
theme.border_marked = tn.orange

-- Taglist
theme.taglist_bg_focus    = tn.bg_highlight
theme.taglist_fg_focus    = tn.cyan
theme.taglist_bg_occupied = tn.bg
theme.taglist_fg_occupied = tn.magenta
theme.taglist_bg_empty    = tn.bg
theme.taglist_fg_empty    = tn.terminal_black

-- Tasklist
theme.tasklist_bg_focus  = tn.bg_highlight
theme.tasklist_fg_focus  = tn.fg
theme.tasklist_bg_normal = tn.bg
theme.tasklist_fg_normal = tn.fg_dark

return theme
