local gfs = require("gears.filesystem")

local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

-- Gruvbox Dark Palette
local gbox = {
    bg0       = "#282828",
    bg1       = "#3c3836",
    bg2       = "#504945",
    fg0       = "#fbf1c7",
    fg1       = "#ebdbb2",
    fg4       = "#a89984",
    red       = "#fb4934",
    green     = "#b8bb26",
    yellow    = "#fabd2f",
    blue      = "#83a598",
    purple    = "#d3869b",
    aqua      = "#8ec07c",
    orange    = "#fe8019",
    gray      = "#928374",
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
theme.bg_normal     = gbox.bg0
theme.bg_focus      = gbox.bg1
theme.bg_urgent     = gbox.red
theme.bg_minimize   = gbox.bg2
theme.bg_systray    = gbox.bg0

theme.fg_normal     = gbox.fg1
theme.fg_focus      = gbox.orange
theme.fg_urgent     = gbox.bg0
theme.fg_minimize   = gbox.gray

theme.border_normal = gbox.bg2
theme.border_focus  = gbox.orange
theme.border_marked = gbox.yellow

-- Taglist
theme.taglist_bg_focus    = gbox.bg1
theme.taglist_fg_focus    = gbox.orange
theme.taglist_bg_occupied = gbox.bg0
theme.taglist_fg_occupied = gbox.green
theme.taglist_bg_empty    = gbox.bg0
theme.taglist_fg_empty    = gbox.gray

-- Tasklist
theme.tasklist_bg_focus  = gbox.bg1
theme.tasklist_fg_focus  = gbox.fg0
theme.tasklist_bg_normal = gbox.bg0
theme.tasklist_fg_normal = gbox.fg1

return theme
