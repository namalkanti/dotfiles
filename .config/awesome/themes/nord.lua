local gfs = require("gears.filesystem")

local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

-- Nord Palette
local nord = {
    nord0  = "#2e3440",
    nord1  = "#3b4252",
    nord2  = "#434c5e",
    nord3  = "#4c566a",
    nord4  = "#d8dee9",
    nord5  = "#e5e9f0",
    nord6  = "#eceff4",
    nord7  = "#8fbcbb",
    nord8  = "#88c0d0",
    nord9  = "#81a1c1",
    nord10 = "#5e81ac",
    nord11 = "#bf616a",
    nord12 = "#d08770",
    nord13 = "#ebcb8b",
    nord14 = "#a3be8c",
    nord15 = "#b48ead",
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
theme.bg_normal     = nord.nord0
theme.bg_focus      = nord.nord2
theme.bg_urgent     = nord.nord11
theme.bg_minimize   = nord.nord1
theme.bg_systray    = nord.nord1

theme.fg_normal     = nord.nord4
theme.fg_focus      = nord.nord8
theme.fg_urgent     = nord.nord0
theme.fg_minimize   = nord.nord3

theme.border_normal = nord.nord3
theme.border_focus  = nord.nord8
theme.border_marked = nord.nord13

-- Taglist
theme.taglist_bg_focus    = nord.nord2
theme.taglist_fg_focus    = nord.nord8
theme.taglist_bg_occupied = nord.nord0
theme.taglist_fg_occupied = nord.nord7
theme.taglist_bg_empty    = nord.nord0
theme.taglist_fg_empty    = nord.nord3

-- Tasklist
theme.tasklist_bg_focus  = nord.nord2
theme.tasklist_fg_focus  = nord.nord6
theme.tasklist_bg_normal = nord.nord0
theme.tasklist_fg_normal = nord.nord4

-- Titlebar
theme.titlebar_bg_normal = nord.nord1
theme.titlebar_bg_focus  = nord.nord2
theme.titlebar_fg_normal = nord.nord4
theme.titlebar_fg_focus  = nord.nord6

local cinnamon = "/home/namalkanti/.themes/Adapta-Nokto/metacity-1/"

theme.titlebar_close_button_normal              = cinnamon .. "button_close.svg"
theme.titlebar_close_button_focus               = cinnamon .. "button_close.svg"
theme.titlebar_close_button_normal_hover        = cinnamon .. "button_close_prelight.svg"
theme.titlebar_close_button_focus_hover         = cinnamon .. "button_close_prelight.svg"

theme.titlebar_minimize_button_normal           = cinnamon .. "button_minimize.svg"
theme.titlebar_minimize_button_focus            = cinnamon .. "button_minimize.svg"
theme.titlebar_minimize_button_normal_hover     = cinnamon .. "button_minimize_prelight.svg"
theme.titlebar_minimize_button_focus_hover      = cinnamon .. "button_minimize_prelight.svg"

theme.titlebar_maximized_button_normal_inactive       = cinnamon .. "button_maximize.svg"
theme.titlebar_maximized_button_focus_inactive        = cinnamon .. "button_maximize.svg"
theme.titlebar_maximized_button_normal_inactive_hover = cinnamon .. "button_maximize_prelight.svg"
theme.titlebar_maximized_button_focus_inactive_hover  = cinnamon .. "button_maximize_prelight.svg"
theme.titlebar_maximized_button_normal_active         = cinnamon .. "max_button_unmaximize.svg"
theme.titlebar_maximized_button_focus_active          = cinnamon .. "max_button_unmaximize.svg"
theme.titlebar_maximized_button_normal_active_hover   = cinnamon .. "max_button_unmaximize_prelight.svg"
theme.titlebar_maximized_button_focus_active_hover    = cinnamon .. "max_button_unmaximize_prelight.svg"

return theme
