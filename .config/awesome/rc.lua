pcall(require, "luarocks.loader")

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
local beautiful     = require("beautiful")
local naughty       = require("naughty")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Startup errors",
        text   = awesome.startup_errors,
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Runtime error",
            text   = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
-- }}}

-- {{{ Globals
local modkey      = "Mod1"   -- Alt
local terminal    = "wezterm"
local filemanager = "thunar"

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}
-- }}}

require("naughty_config")

-- Load modules (order matters: keys before rules, wibar last)
local keys   = require("keys")
local rules  = require("rules")
local wibar  = require("wibar")

-- Sharedtags support: disabled for now (no-op) until everything else is
-- confirmed stable. Uncomment to re-enable; keys.lua already has the
-- conditional branches in place to handle it once tags/st_mod are passed in.
-- local has_sharedtags, sharedtags = pcall(require, "sharedtags")
-- local tags = nil
--
-- if has_sharedtags then
--     tags = sharedtags({
--         { name = "1", layout = awful.layout.layouts[1] },
--         { name = "2", layout = awful.layout.layouts[1] },
--         { name = "3", layout = awful.layout.layouts[1] },
--         { name = "4", layout = awful.layout.layouts[1] },
--         { name = "5", layout = awful.layout.layouts[1], screen = 2 },
--         { name = "6", layout = awful.layout.layouts[1] },
--         { name = "7", layout = awful.layout.layouts[1] },
--         { name = "8", layout = awful.layout.layouts[1] },
--         { name = "9", layout = awful.layout.layouts[1] },
--     })
-- end
--
-- keys.init(modkey, terminal, filemanager, tags, has_sharedtags and sharedtags or nil)

keys.init(modkey, terminal, filemanager)
rules.init(keys.client, keys.buttons)
wibar.init(modkey)

require("autostart")

-- {{{ Signals

-- Checks for windows on disconnected monitors on startup
client.connect_signal("manage", function(c)
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        awful.placement.no_offscreen(c)
    end
end)

-- Sets up titlebars for requesting windows
client.connect_signal("request::titlebars", function(c)
    local wibox  = require("wibox")
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )
    awful.titlebar(c):setup {
        { awful.titlebar.widget.iconwidget(c), buttons = buttons,
          layout = wibox.layout.fixed.horizontal },
        { { align = "center", widget = awful.titlebar.widget.titlewidget(c) },
          buttons = buttons, layout = wibox.layout.flex.horizontal },
        { awful.titlebar.widget.floatingbutton(c),
          awful.titlebar.widget.maximizedbutton(c),
          awful.titlebar.widget.closebutton(c),
          layout = wibox.layout.fixed.horizontal() },
        layout = wibox.layout.align.horizontal,
    }
end)

-- Focus follows mouse 
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
