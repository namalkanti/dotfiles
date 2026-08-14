# Note: AwesomeWM Setup & Daily Driver Session Configuration

**Date**: 2025-08-13
**Plan**: `awesomewm-setup.md`

## Context & Objectives
Pivoted from i3 to AwesomeWM on Arch Linux using LightDM as the display manager.
- Replaced Polybar, Dunst, and Feh with native AwesomeWM equivalents (`wibar`, `naughty`, `gears.wallpaper`).
- Kept shared utilities: `picom` (compositor), `rofi` (launcher & power menu), `wezterm` (terminal), `thunar` (file manager), and `nm-applet` (network status).
- Preserved i3 dotfiles in `~/.config/i3/` for reference.

## Key Architecture & Configuration Decisions
1. **Modular Configuration**:
   - `~/.config/awesome/rc.lua` — Entry point & signals
   - `~/.config/awesome/keys.lua` — All hotkeys (`Alt` modifier, `Alt+hjkl` navigation, `Shift+Alt+hjkl` window move, `Alt+1..9` tags, Pactl media/brightness keys)
   - `~/.config/awesome/rules.lua` — Window rules & floating overrides (`Pavucontrol`, popups, non-maximized tiling)
   - `~/.config/awesome/wibar.lua` — Floating 3D split-island bar with native volume (`pavucontrol` launch on right-click), battery detection (`BAT0`), system tray, and rounded bullet tag indicators
   - `~/.config/awesome/autostart.lua` — Background daemons (`picom`, `nm-applet`, `blueman-applet`, `tailscale-systray`)
   - `~/.config/awesome/naughty_config.lua` — Native desktop notification configuration
2. **Themes & Palette Preset Manager**:
   - Built modular themes directory: `~/.config/awesome/themes/` (`catppuccin-mocha.lua`, `tokyo-night.lua`, `nord.lua`, `dracula.lua`, `gruvbox-dark.lua`)
   - Active theme controlled via `~/.config/awesome/theme.lua` (currently set to Nord)
3. **Machine-Local Wallpaper**:
   - Loads from `~/Pictures/wallpaper/wallpaper.png` or `wallpaper.jpg` automatically.
4. **Compositor & Launcher Consistency**:
   - Picom (`~/.config/picom/picom.conf`): GLX backend, vsync, 10px rounded corners, GLX shadows, fading, and background blur.
   - Rofi (`~/.config/rofi/config.rasi`): Matches 10px rounded corner aesthetic.
   - Power Menu (`~/.local/bin/rofi-power-menu.sh`): Bound to `Shift + Alt + e` with `Exit Awesome` (`awesome-client "awesome.quit()"`).
5. **XDG Menu Exclusions**:
   - Converted Cinnamon `.menu` exclusions into XDG `NoDisplay=true` overrides in `~/.local/share/applications/` to keep Rofi clean.

## Important File Paths
- `~/.config/awesome/rc.lua`
- `~/.config/awesome/theme.lua`
- `~/.config/awesome/themes/`
- `~/.config/awesome/wibar.lua`
- `~/.config/picom/picom.conf`
- `~/.config/rofi/config.rasi`
- `~/.local/bin/rofi-power-menu.sh`
- `~/Pictures/wallpaper/`
