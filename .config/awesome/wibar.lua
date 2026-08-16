local gears     = require("gears")
local gfs       = require("gears.filesystem")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local M = {}

-- Per-screen UI scale: screen 1 (this desktop's 2K primary, and always the
-- only screen on the laptop) stays at 1.0; screen 2+ (4K here) scales up.
-- 1.5 matches the actual resolution ratio (3840/2560 = 2160/1440 = 1.5),
-- not an arbitrary guess.
local function ui_scale(s)
    return (s.index >= 2) and 1.5 or 1.0
end

-- All raw pixel dimensions used to build the bar, at 1x (screen 1) scale.
-- scale_dims() below produces a scaled copy of this per screen.
local BASE_DIM = {
    bar_height        = 44,
    outer_margin      = 4,
    inner_margin_v    = 4,
    inner_margin_h    = 10,
    island_radius     = 8,
    entry_radius      = 6,
    entry_pad         = 8,
    tasklist_spacing  = 8,
    tasklist_max_item = 220,
    left_spacing      = 4,
    right_spacing     = 4,
    launcher_icon     = 28,
    launcher_pad      = 2,
    layoutbox_icon    = 28,
    tray_size         = 28,
}

local function scale_dims(base, scale)
    local out = { scale = scale }
    for k, v in pairs(base) do
        out[k] = math.floor(v * scale + 0.5)
    end
    return out
end

local function scaled_font(base_font, scale)
    local prefix, size = base_font:match("^(.-)(%d+)$")
    if not prefix or not size then return base_font end
    return prefix .. math.floor(tonumber(size) * scale + 0.5)
end

-- Helper function to create an elevated island widget box (3D depth / split bar effect)
local function create_island(widget, dim, bg_color)
    return wibox.widget {
        {
            {
                widget,
                top    = dim.inner_margin_v,
                bottom = dim.inner_margin_v,
                left   = dim.inner_margin_h,
                right  = dim.inner_margin_h,
                widget = wibox.container.margin
            },
            bg           = bg_color or beautiful.bg_normal or "#1e1e2e",
            border_width = 1,
            border_color = beautiful.border_focus or "#89b4fa",
            shape        = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, dim.island_radius)
            end,
            widget       = wibox.container.background
        },
        top    = dim.outer_margin,
        bottom = dim.outer_margin,
        left   = dim.outer_margin,
        right  = dim.outer_margin,
        widget = wibox.container.margin
    }
end

-- Custom Volume Widget using pactl
local function create_volume_widget(dim)
    local vol_text = wibox.widget.textbox()
    vol_text.font = scaled_font(beautiful.font or "MesloLGS Nerd Font 12", dim.scale)

    local function update_volume()
        awful.spawn.easy_async("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
            local vol = stdout:match("(%d+)%%")
            if vol then
                awful.spawn.easy_async("pactl get-sink-mute @DEFAULT_SINK@", function(mute_out)
                    if mute_out:match("mute:%s+yes") or mute_out:match("yes") then
                        vol_text.text = "󰝟 Muted"
                    else
                        vol_text.text = string.format("󰕾 %d%%", tonumber(vol))
                    end
                end)
            else
                vol_text.text = "󰕾 --%"
            end
        end)
    end

    update_volume()

    local vol_widget = wibox.widget {
        vol_text,
        widget = wibox.container.margin
    }

    vol_widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn.easy_async("pactl set-sink-mute @DEFAULT_SINK@ toggle", function() update_volume() end)
        end),
        awful.button({}, 3, function()
            awful.spawn("pavucontrol")
        end),
        awful.button({}, 4, function()
            awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ +5%", function() update_volume() end)
        end),
        awful.button({}, 5, function()
            awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ -5%", function() update_volume() end)
        end)
    ))

    -- Timer update every 3 seconds
    gears.timer {
        timeout   = 3,
        autostart = true,
        call_now  = true,
        callback  = update_volume
    }

    return vol_widget
end

-- Custom Battery Widget
local function create_battery_widget(dim)
    local bat_text = wibox.widget.textbox()
    bat_text.font = scaled_font(beautiful.font or "MesloLGS Nerd Font 12", dim.scale)

    local function update_battery()
        awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT0/capacity 2>/dev/null", function(cap_out)
            local cap = tonumber(cap_out:match("%d+"))
            if not cap then
                bat_text.text = ""
                return
            end

            awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT0/status 2>/dev/null", function(stat_out)
                local status = stat_out:gsub("%s+", "")
                local icon = "󰁹"
                if status == "Charging" then
                    icon = "󰂄"
                elseif cap <= 20 then
                    icon = "󰂎"
                elseif cap <= 50 then
                    icon = "󰁽"
                end
                bat_text.text = string.format("%s %d%%", icon, cap)
            end)
        end)
    end

    update_battery()

    gears.timer {
        timeout   = 10,
        autostart = true,
        call_now  = true,
        callback  = update_battery
    }

    return bat_text
end

-- Custom Weather and Sunset Widget
local function create_weather_widget(dim)
    local weather_text = wibox.widget.textbox()
    weather_text.font = scaled_font(beautiful.font or "MesloLGS Nerd Font 12", dim.scale)
    weather_text.text = "󰖐 Loading weather..."

    local function update_weather()
        local cmd = [[curl -s --max-time 5 "wttr.in?format=%c+%t|%s&m"]]
        awful.spawn.easy_async_with_shell(cmd, function(stdout)
            local raw = stdout:gsub("%s+$", "")
            if raw == "" or raw:find("<html") or raw:find("Unknown location") then
                weather_text.text = "󰖐 Weather unavailable"
                return
            end

            local weather, sunset = raw:match("^(.-)|(.*)$")
            if weather and sunset then
                local parse_cmd = string.format("date -d '%s' +'%%-I:%%M %%p' 2>/dev/null || echo '%s'", sunset, sunset)
                awful.spawn.easy_async_with_shell(parse_cmd, function(sunset_out)
                    local formatted_sunset = sunset_out:gsub("%s+$", "")
                    weather_text.text = string.format("%s  •  🌇 Sunset %s", weather, formatted_sunset)
                end)
            else
                weather_text.text = raw
            end
        end)
    end

    update_weather()

    gears.timer {
        timeout   = 900,
        autostart = true,
        call_now  = false,
        callback  = update_weather
    }

    local widget = wibox.widget {
        weather_text,
        widget = wibox.container.margin
    }
    widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            weather_text.text = "󰖐 Refreshing..."
            update_weather()
        end)
    ))

    return widget
end

-- Custom Arch Linux Menu Launcher Island
local function create_launcher_widget(dim)
    local home = os.getenv("HOME") or "/home/namalkanti"
    local icon_path = home .. "/Pictures/icons/archlinux.svg"
    if not gfs.file_readable(icon_path) then
        icon_path = "/usr/share/pixmaps/archlinux-logo.svg"
    end

    local icon_widget = wibox.widget {
        image         = icon_path,
        resize        = true,
        forced_width  = dim.launcher_icon,
        forced_height = dim.launcher_icon,
        widget        = wibox.widget.imagebox
    }

    local launcher = wibox.widget {
        icon_widget,
        top    = dim.launcher_pad,
        bottom = dim.launcher_pad,
        left   = dim.launcher_pad,
        right  = dim.launcher_pad,
        widget = wibox.container.margin
    }

    launcher:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn("rofi -show drun")
        end)
    ))

    return launcher
end

-- Full taskbar setup
function M.init(modkey)
    beautiful.taglist_squares_sel   = nil
    beautiful.taglist_squares_unsel = nil

    local taglist_buttons = gears.table.join(
        awful.button({},         1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
            if client.focus then client.focus:move_to_tag(t) end
        end),
        awful.button({},         3, awful.tag.viewtoggle),
        awful.button({},         4, function(t) awful.tag.viewnext(t.screen) end),
        awful.button({},         5, function(t) awful.tag.viewprev(t.screen) end)
    )

    local tasklist_buttons = gears.table.join(
        awful.button({}, 1, function(c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", { raise = true })
            end
        end),
        awful.button({}, 3, function()
            awful.menu.client_list({ theme = { width = 250 } })
        end),
        awful.button({}, 4, function() awful.client.focus.byidx( 1) end),
        awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
    )

    root.buttons(gears.table.join(
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    ))

    awful.screen.connect_for_each_screen(function(s)
        local dim = scale_dims(BASE_DIM, ui_scale(s))

        -- Set wallpaper via gears.wallpaper (checks ~/Pictures/wallpaper/ first)
        local home = os.getenv("HOME") or "/home/namalkanti"
        local wp_path = home .. "/Pictures/wallpaper/wallpaper.png"
        if not gfs.file_readable(wp_path) then
            wp_path = home .. "/Pictures/wallpaper/wallpaper.jpg"
        end

        if gfs.file_readable(wp_path) then
            gears.wallpaper.maximized(wp_path, s, true)
        elseif beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)
        end

        -- Create default tags per screen only if sharedtags hasn't already populated them
        if not s.tags or #s.tags == 0 then
            awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
        end

        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox.forced_width  = dim.layoutbox_icon
        s.mylayoutbox.forced_height = dim.layoutbox_icon
        s.mylayoutbox:buttons(gears.table.join(
            awful.button({}, 1, function() awful.layout.inc( 1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc( 1) end),
            awful.button({}, 5, function() awful.layout.inc(-1) end)
        ))

        s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
            style   = {
                shape = function(cr, w, h)
                    gears.shape.rounded_rect(cr, w, h, dim.entry_radius)
                end,
            },
            widget_template = {
                {
                    {
                        {
                            id     = 'text_role',
                            widget = wibox.widget.textbox,
                            font   = scaled_font(beautiful.taglist_font or "MesloLGS Nerd Font Bold 12", dim.scale),
                        },
                        {
                            id     = 'dot_role',
                            widget = wibox.widget.textbox,
                            text   = "•",
                            font   = scaled_font("MesloLGS Nerd Font 12", dim.scale),
                        },
                        spacing = 2,
                        layout  = wibox.layout.fixed.horizontal,
                    },
                    left   = dim.entry_pad,
                    right  = dim.entry_pad,
                    widget = wibox.container.margin,
                },
                id     = 'background_role',
                widget = wibox.container.background,
                create_callback = function(self, c3, index, objects)
                    local dot = self:get_children_by_id('dot_role')[1]
                    if dot then
                        dot.visible = (#c3:clients() > 0)
                    end
                end,
                update_callback = function(self, c3, index, objects)
                    local dot = self:get_children_by_id('dot_role')[1]
                    if dot then
                        dot.visible = (#c3:clients() > 0)
                    end
                end,
            },
        }

        s.mytasklist = awful.widget.tasklist {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons,
            style   = {
                shape = function(cr, w, h)
                    gears.shape.rounded_rect(cr, w, h, dim.entry_radius)
                end,
            },
            layout  = {
                spacing         = dim.tasklist_spacing,
                max_widget_size = dim.tasklist_max_item,
                layout          = wibox.layout.flex.horizontal
            },
            widget_template = {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        {
                            id     = 'text_role',
                            widget = wibox.widget.textbox,
                            font   = scaled_font(beautiful.font or "MesloLGS Nerd Font 12", dim.scale),
                        },
                        spacing = 6,
                        layout  = wibox.layout.fixed.horizontal,
                    },
                    left   = dim.entry_pad,
                    right  = dim.entry_pad,
                    widget = wibox.container.margin,
                },
                id     = 'background_role',
                widget = wibox.container.background,
            },
        }

        local is_primary = (s == screen.primary)

        local right_widgets = wibox.layout.fixed.horizontal()
        right_widgets.spacing = dim.right_spacing

        if is_primary then
            local volume_widget  = create_volume_widget(dim)
            local battery_widget = create_battery_widget(dim)

            right_widgets:add(create_island(volume_widget, dim))

            -- Only create battery island if system has a battery
            if gfs.file_readable("/sys/class/power_supply/BAT0/capacity") then
                right_widgets:add(create_island(battery_widget, dim))
            end

            local tray = wibox.widget.systray()
            tray:set_base_size(dim.tray_size)
            -- The systray widget paints its own flat rectangular background
            -- (beautiful.bg_systray) directly via a C-level call, bypassing
            -- our rounded_rect shape entirely, and ignores alpha (an all-zero
            -- ARGB string renders as opaque black, not transparent). Match
            -- the island's own fill color instead so the square patch blends
            -- in rather than needing to be see-through.
            beautiful.bg_systray = beautiful.bg_normal or "#1e1e2e"
            right_widgets:add(create_island(tray, dim))

            -- The systray widget doesn't emit widget::layout_changed when an
            -- icon registers/unregisters externally (XEMBED, outside Lua),
            -- so the bar never re-runs layout to give it more/less room.
            -- Poll the count and force a relayout when it changes.
            local last_tray_count = awesome.systray()
            gears.timer {
                timeout   = 1,
                autostart = true,
                call_now  = false,
                callback  = function()
                    local count = awesome.systray()
                    if count ~= last_tray_count then
                        last_tray_count = count
                        tray:emit_signal("widget::layout_changed")
                    end
                end
            }

            local clock = wibox.widget.textclock(" %a %b %d  %I:%M %p ")
            clock.font = scaled_font(beautiful.font or "MesloLGS Nerd Font 12", dim.scale)
            right_widgets:add(create_island(clock, dim))
        else
            local weather_widget = create_weather_widget(dim)
            right_widgets:add(create_island(weather_widget, dim))
        end

        right_widgets:add(create_island(s.mylayoutbox, dim))

        -- Floating bar with transparent background
        s.mywibox = awful.wibar({
            position = "top",
            screen   = s,
            height   = dim.bar_height,
            bg       = "#00000000",
        })

        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left Island: Launcher + Tags
                layout  = wibox.layout.fixed.horizontal,
                spacing = dim.left_spacing,
                create_island(create_launcher_widget(dim), dim),
                create_island(s.mytaglist, dim),
            },
            create_island(s.mytasklist, dim), -- Middle: Tasks, clamped to remaining space
            right_widgets,
        }
    end)
end

return M
