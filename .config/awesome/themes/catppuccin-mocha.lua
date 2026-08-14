local gfs = require("gears.filesystem")

local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

-- Catppuccin Mocha Palette
local mocha = {
    rosewater = "#f5e0dc",
    flamingo  = "#f2cdcd",
    pink      = "#f5c2e7",
    mauve     = "#cba6f7",
    red       = "#f38ba8",
    maroon    = "#eba0ac",
    peach     = "#fab387",
    yellow    = "#f9e2af",
    green     = "#a6e3a1",
    teal      = "#94e2d5",
    sky       = "#89dceb",
    sapphire  = "#74c7ec",
    blue      = "#89b4fa",
    lavender  = "#b4befe",
    text      = "#cdd6f4",
    subtext1  = "#bac2de",
    subtext0  = "#a6adc8",
    overlay2  = "#9399b2",
    overlay1  = "#7f849c",
    overlay0  = "#6c7086",
    surface2  = "#585b70",
    surface1  = "#45475a",
    surface0  = "#313244",
    base      = "#1e1e2e",
    mantle    = "#181825",
    crust     = "#11111b",
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
theme.bg_normal     = mocha.base
theme.bg_focus      = mocha.surface0
theme.bg_urgent     = mocha.red
theme.bg_minimize   = mocha.surface1
theme.bg_systray    = mocha.mantle

theme.fg_normal     = mocha.subtext1
theme.fg_focus      = mocha.mauve
theme.fg_urgent     = mocha.base
theme.fg_minimize   = mocha.overlay0

theme.border_normal = mocha.surface0
theme.border_focus  = mocha.mauve
theme.border_marked = mocha.peach

-- Taglist
theme.taglist_bg_focus    = mocha.surface0
theme.taglist_fg_focus    = mocha.mauve
theme.taglist_bg_occupied = mocha.base
theme.taglist_fg_occupied = mocha.blue
theme.taglist_bg_empty    = mocha.base
theme.taglist_fg_empty    = mocha.overlay0

-- Tasklist
theme.tasklist_bg_focus  = mocha.surface0
theme.tasklist_fg_focus  = mocha.text
theme.tasklist_bg_normal = mocha.base
theme.tasklist_fg_normal = mocha.subtext0

return theme
