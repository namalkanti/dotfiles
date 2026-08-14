local awful = require("awful")

awful.spawn.with_shell("xrdb -merge ~/.Xresources")
awful.spawn.with_shell("setxkbmap -option caps:swapescape")
awful.spawn.with_shell("killall picom; picom --daemon")
awful.spawn.with_shell("pgrep -x nm-applet      > /dev/null || nm-applet")
awful.spawn.with_shell("pgrep -x blueman-applet  > /dev/null || blueman-applet")
awful.spawn.with_shell("killall pasystray cbatticon 2>/dev/null; true")
awful.spawn.with_shell("systemctl is-active --quiet tailscaled && (pgrep -f tailscale-systray > /dev/null || tailscale-systray &)")
