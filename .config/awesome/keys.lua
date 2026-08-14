local gears         = require("gears")
local awful         = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local M = {}

function M.init(modkey, terminal, filemanager)
    -- {{{ Global keys
    local globalkeys = gears.table.join(
        -- Focus — directional
        awful.key({ modkey }, "h", function() awful.client.focus.bydirection("left")  end,
            { description = "focus left",  group = "client" }),
        awful.key({ modkey }, "l", function() awful.client.focus.bydirection("right") end,
            { description = "focus right", group = "client" }),
        awful.key({ modkey }, "j", function() awful.client.focus.bydirection("down")  end,
            { description = "focus down",  group = "client" }),
        awful.key({ modkey }, "k", function() awful.client.focus.bydirection("up")    end,
            { description = "focus up",    group = "client" }),

        -- Move — directional swap
        awful.key({ modkey, "Shift" }, "h", function() awful.client.swap.bydirection("left")  end,
            { description = "move left",  group = "client" }),
        awful.key({ modkey, "Shift" }, "l", function() awful.client.swap.bydirection("right") end,
            { description = "move right", group = "client" }),
        awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.bydirection("down")  end,
            { description = "move down",  group = "client" }),
        awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.bydirection("up")    end,
            { description = "move up",    group = "client" }),

        -- Focus cycle
        awful.key({ modkey }, "Tab", function()
            awful.client.focus.byidx(1)
        end, { description = "focus next", group = "client" }),
        awful.key({ modkey, "Shift" }, "Tab", function()
            awful.client.focus.byidx(-1)
        end, { description = "focus previous", group = "client" }),

        -- Layout cycling
        awful.key({ modkey }, "space",          function() awful.layout.inc( 1) end,
            { description = "next layout",     group = "layout" }),
        awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
            { description = "previous layout", group = "layout" }),

        -- Master width
        awful.key({ modkey, "Control" }, "h", function() awful.tag.incmwfact(-0.05) end,
            { description = "shrink master", group = "layout" }),
        awful.key({ modkey, "Control" }, "l", function() awful.tag.incmwfact( 0.05) end,
            { description = "grow master",   group = "layout" }),

        -- Launchers
        awful.key({ modkey, "Shift" }, "t", function() awful.spawn(terminal)    end,
            { description = "terminal",       group = "launcher" }),
        awful.key({ modkey, "Shift" }, "n", function() awful.spawn(filemanager) end,
            { description = "file manager",   group = "launcher" }),
        awful.key({ modkey }, "q", function() awful.spawn("rofi -show drun")    end,
            { description = "app launcher",   group = "launcher" }),
        awful.key({ modkey }, "e", function() awful.spawn("rofi -show window")  end,
            { description = "window switcher", group = "launcher" }),
        awful.key({ modkey, "Shift" }, "e", function()
            awful.spawn(os.getenv("HOME") .. "/.local/bin/rofi-power-menu.sh")
        end, { description = "power menu", group = "launcher" }),

        -- Lock screen
        awful.key({ "Control", modkey }, "l", function()
            awful.spawn("i3lock -c 000000")
        end, { description = "lock screen", group = "session" }),

        -- Multi-tag (Alt+Ctrl+1..9 = toggle tag on client; Alt+Shift+Ctrl+1..9 = toggle tag view)
        -- Uses standard awful.key (no keygrabber), zero risk of locking input.
        -- Handled in tag loop below.

        -- Awesome control
        awful.key({ modkey, "Control" }, "r", awesome.restart,
            { description = "reload awesome", group = "awesome" }),
        awful.key({ modkey }, "s", hotkeys_popup.show_help,
            { description = "hotkeys help",   group = "awesome" }),

        -- Volume
        awful.key({}, "XF86AudioRaiseVolume", function()
            awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
        end, { description = "volume up",   group = "media" }),
        awful.key({}, "XF86AudioLowerVolume", function()
            awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
        end, { description = "volume down", group = "media" }),
        awful.key({}, "XF86AudioMute", function()
            awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
        end, { description = "mute",        group = "media" }),

        -- Brightness
        awful.key({}, "XF86MonBrightnessUp", function()
            awful.spawn("brightnessctl set +10%", false)
        end, { description = "brightness up",   group = "media" }),
        awful.key({}, "XF86MonBrightnessDown", function()
            awful.spawn("brightnessctl set 10%-", false)
        end, { description = "brightness down", group = "media" }),

        -- Playback
        awful.key({}, "XF86AudioPlay", function()
            awful.spawn("playerctl play-pause", false)
        end, { description = "play/pause",  group = "media" }),
        awful.key({}, "XF86AudioNext", function()
            awful.spawn("playerctl next", false)
        end, { description = "next track",  group = "media" }),
        awful.key({}, "XF86AudioPrev", function()
            awful.spawn("playerctl previous", false)
        end, { description = "prev track",  group = "media" })
    )

    -- Tag switching, move-to-tag, and multi-tag toggling
    for i = 1, 9 do
        globalkeys = gears.table.join(globalkeys,
            -- View tag exclusively
            awful.key({ modkey }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then tag:view_only() end
                end,
                { description = "view tag " .. i, group = "tag" }),
            -- Move client to tag exclusively
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then client.focus:move_to_tag(tag) end
                    end
                end,
                { description = "move to tag " .. i, group = "tag" }),
            -- Toggle tag on client (multi-tag)
            awful.key({ modkey, "Control" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then client.focus:toggle_tag(tag) end
                    end
                end,
                { description = "toggle tag " .. i .. " on client", group = "tag" }),
            -- Toggle tag view (multi-view)
            awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then awful.tag.viewtoggle(tag) end
                end,
                { description = "toggle tag view " .. i, group = "tag" })
        )
    end

    root.keys(globalkeys)
    -- }}}

    -- {{{ Client keys
    M.client = gears.table.join(
        awful.key({ modkey }, "x", function(c) c:kill() end,
            { description = "close", group = "client" }),
        awful.key({ modkey }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "fullscreen", group = "client" }),
        awful.key({ modkey, "Shift" }, "f", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "maximize", group = "client" }),
        awful.key({ modkey }, "r", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "maximize", group = "client" })
    )
    -- }}}

    -- {{{ Client mouse buttons
    M.buttons = gears.table.join(
        awful.button({}, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end),
        awful.button({ modkey }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ modkey }, 3, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )
    -- }}}
end

return M
