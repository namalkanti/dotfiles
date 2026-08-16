local gears         = require("gears")
local awful         = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local has_sharedtags, sharedtags = pcall(require, "sharedtags")

local M = {}

-- function M.init(modkey, terminal, filemanager) -- vanilla per-screen tags signature
function M.init(modkey, terminal, filemanager, tags, st_mod)
    if st_mod then
        sharedtags = st_mod
        has_sharedtags = true
    end
    -- Cyclic screen navigation: wraps around instead of stopping at the last
    -- screen in a direction. target_only=true skips changing focus, for the
    -- "send window to screen" bindings which only need the target screen.
    local function screen_relative(offset, target_only)
        local cur = awful.screen.focused()
        local idx = ((cur.index - 1 + offset) % screen.count()) + 1
        local target = screen[idx]
        if not target_only then
            awful.screen.focus(target)
        end
        return target
    end

    -- {{{ Global keys
    local globalkeys = gears.table.join(
        -- Focus — directional (crosses screens)
        awful.key({ modkey }, "h", function() awful.client.focus.global_bydirection("left")  end,
            { description = "focus left",  group = "client" }),
        awful.key({ modkey }, "l", function() awful.client.focus.global_bydirection("right") end,
            { description = "focus right", group = "client" }),
        awful.key({ modkey }, "j", function() awful.client.focus.global_bydirection("down")  end,
            { description = "focus down",  group = "client" }),
        awful.key({ modkey }, "k", function() awful.client.focus.global_bydirection("up")    end,
            { description = "focus up",    group = "client" }),

        -- Move — directional swap (crosses screens)
        awful.key({ modkey, "Shift" }, "h", function() awful.client.swap.global_bydirection("left")  end,
            { description = "move left",  group = "client" }),
        awful.key({ modkey, "Shift" }, "l", function() awful.client.swap.global_bydirection("right") end,
            { description = "move right", group = "client" }),
        awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.global_bydirection("down")  end,
            { description = "move down",  group = "client" }),
        awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.global_bydirection("up")    end,
            { description = "move up",    group = "client" }),

        -- Screen navigation (next/previous monitor, wraps around)
        awful.key({ modkey }, "p", function() screen_relative(-1) end,
            { description = "focus previous screen", group = "screen" }),
        awful.key({ modkey }, "n", function() screen_relative(1) end,
            { description = "focus next screen",     group = "screen" }),

        awful.key({ modkey, "Shift" }, "p", function()
            if client.focus then client.focus:move_to_screen(screen_relative(-1, true)) end
        end, { description = "send window to previous screen", group = "screen" }),

        awful.key({ modkey, "Shift" }, "n", function()
            if client.focus then client.focus:move_to_screen(screen_relative(1, true)) end
        end, { description = "send window to next screen", group = "screen" }),

        -- Swap active tags on dual monitors
        awful.key({ modkey }, "s", function()
            if has_sharedtags and screen.count() >= 2 then
                local s1 = screen[1]
                local s2 = screen[2]
                local t1 = s1.selected_tag
                local t2 = s2.selected_tag
                if t1 and t2 and t1 ~= t2 then
                    sharedtags.movetag(t1, s2)
                    sharedtags.movetag(t2, s1)
                end
            end
        end, { description = "swap active tags between monitors", group = "screen" }),
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
        awful.key({ modkey, "Shift" }, "-", function() awful.tag.incmwfact(-0.05) end,
            { description = "shrink master", group = "layout" }),
        awful.key({ modkey, "Shift" }, "=", function() awful.tag.incmwfact( 0.05) end,
            { description = "grow master",   group = "layout" }),

        -- Launchers
        awful.key({ modkey, "Shift" }, "t", function() awful.spawn(terminal)    end,
            { description = "terminal",       group = "launcher" }),
        awful.key({ modkey, "Shift" }, "f", function() awful.spawn(filemanager) end,
            { description = "file manager",   group = "launcher" }),
        awful.key({ modkey }, "q", function() awful.spawn("rofi -show drun")    end,
            { description = "app launcher",   group = "launcher" }),
        awful.key({ modkey }, "e", function() awful.spawn("rofi -show window")  end,
            { description = "window switcher", group = "launcher" }),
        awful.key({ modkey, "Shift" }, "e", function()
            awful.spawn(os.getenv("HOME") .. "/.local/bin/rofi-power-menu.sh")
        end, { description = "power menu", group = "launcher" }),

        -- Multi-tag (Alt+Ctrl+1..9 = toggle tag on client; Alt+Shift+Ctrl+1..9 = toggle tag view)
        -- Uses standard awful.key (no keygrabber), zero risk of locking input.
        -- Handled in tag loop below.

        -- Awesome control
        awful.key({ modkey, "Control" }, "r", awesome.restart,
            { description = "reload awesome", group = "awesome" }),
        awful.key({ modkey }, "w", hotkeys_popup.show_help,
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
                    if has_sharedtags and tags then
                        local tag = tags[i]
                        if tag then sharedtags.viewonly(tag, screen) end
                    else
                        -- Vanilla per-screen tags fallback
                        local tag = screen.tags[i]
                        if tag then tag:view_only() end
                    end
                end,
                { description = "view tag " .. i, group = "tag" }),
            -- Move client to tag exclusively
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function()
                    if client.focus then
                        if has_sharedtags and tags then
                            local tag = tags[i]
                            if tag then client.focus:move_to_tag(tag) end
                        else
                            -- Vanilla per-screen tags fallback
                            local tag = client.focus.screen.tags[i]
                            if tag then client.focus:move_to_tag(tag) end
                        end
                    end
                end,
                { description = "move to tag " .. i, group = "tag" }),
            -- Toggle tag on client (multi-tag)
            awful.key({ modkey, "Control" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local c = client.focus
                        local s = c.screen
                        if has_sharedtags and tags then
                            local tag = tags[i]
                            if tag then c:toggle_tag(tag) end
                        else
                            -- Vanilla per-screen tags fallback
                            local tag = s.tags[i]
                            if tag then c:toggle_tag(tag) end
                        end
                        awful.layout.arrange(s)
                    end
                end,
                { description = "toggle tag " .. i .. " on client", group = "tag" }),
            -- Toggle tag view (multi-view)
            awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    if has_sharedtags and tags then
                        local tag = tags[i]
                        if tag then sharedtags.viewtoggle(tag, screen) end
                    else
                        -- Vanilla per-screen tags fallback
                        local tag = screen.tags[i]
                        if tag then awful.tag.viewtoggle(tag) end
                    end
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
        awful.key({ modkey, "Shift" }, "r", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
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
