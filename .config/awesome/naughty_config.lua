local naughty  = require("naughty")
local beautiful = require("beautiful")

naughty.config.defaults.position       = "top_right"
naughty.config.defaults.timeout        = 5
naughty.config.defaults.icon_size      = 32
naughty.config.defaults.max_width      = 300
naughty.config.defaults.font           = beautiful.font or "MesloLGS Nerd Font 10"
naughty.config.defaults.border_width   = 1
naughty.config.defaults.margin         = 8
