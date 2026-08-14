local gfs = require("gears.filesystem")

local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

-- Dracula Palette
local dra = {
    bg        = "#282a36",
    current   = "#44475a",
    fg        = "#f8f8f2",
    comment   = "#6272a4",
    cyan      = "#8be9fd",
    green     = "#50fa7b",
    orange    = "#ffb86c",
    pink      = "#ff79c6",
    purple    = "#bd93f9",
    red       = "#ff5555",
    yellow    = "#f1fa8c",
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
theme.bg_normal     = dra.bg
theme.bg_focus      = dra.current
theme.bg_urgent     = dra.red
theme.bg_minimize   = dra.bg
theme.bg_systray    = dra.bg

theme.fg_normal     = dra.fg
theme.fg_focus      = dra.pink
theme.fg_urgent     = dra.bg
theme.fg_minimize   = dra.comment

theme.border_normal = dra.current
theme.border_focus  = dra.purple
theme.border_marked = dra.orange

-- Taglist
theme.taglist_bg_focus    = dra.current
theme.taglist_fg_focus    = dra.pink
theme.taglist_bg_occupied = dra.bg
theme.taglist_fg_occupied = dra.cyan
theme.taglist_bg_empty    = dra.bg
theme.taglist_fg_empty    = dra.comment

-- Tasklist
theme.tasklist_bg_focus  = dra.current
theme.tasklist_fg_focus  = dra.fg
theme.tasklist_bg_normal = dra.bg
theme.tasklist_fg_normal = dra.comment

return theme
