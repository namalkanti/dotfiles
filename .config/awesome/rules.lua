local awful     = require("awful")
local beautiful = require("beautiful")

local M = {}

function M.init(clientkeys, clientbuttons)
    awful.rules.rules = {
        -- Default rule
        { rule = {},
          properties = {
              border_width         = beautiful.border_width,
              border_color         = beautiful.border_normal,
              focus                = awful.client.focus.filter,
              raise                = true,
              keys                 = clientkeys,
              buttons              = clientbuttons,
              screen               = awful.screen.preferred,
              placement            = awful.placement.no_overlap + awful.placement.no_offscreen,
              titlebars_enabled    = false,
              floating             = false,
              size_hints_honor     = false,
              maximized            = false,
              maximized_vertical   = false,
              maximized_horizontal = false,
          }
        },

        -- Always-floating clients
        { rule_any = {
            class = { "Pavucontrol", "Arandr", "Blueman-manager" },
            role  = { "pop-up", "task_dialog", "AlarmWindow" },
            name  = { "Event Tester" },
          },
          properties = { floating = true }
        },

        -- Dialogs get titlebars
        { rule_any = { type = { "dialog" } },
          properties = { titlebars_enabled = true, floating = true }
        },
    }
end

return M
