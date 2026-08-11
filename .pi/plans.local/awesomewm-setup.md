# Task: Set up AwesomeWM as a daily-driver session on Arch and clean up unneeded dependencies

**Status**: Draft — Ready for execution

## References
- `.pi/plans.local/i3-daily-driver-setup.md` — Initial i3 session setup plan (pivoted from)

## Context
- The user is pivoting from an i3 setup to AwesomeWM on Arch Linux (using LightDM as the display manager).
- AwesomeWM provides native equivalents for several standalone utilities used in the i3 plan:
  - Native `wibar` replaces Polybar.
  - Native `naughty` notification library replaces Dunst.
  - Native `gears.wallpaper` replaces Feh.
- Core utilities like `picom` (compositor), `rofi` (application launcher & power menu), `wezterm` (terminal), `thunar` (file manager), and `nm-applet` (network status) remain shared across sessions.
- Keybindings, modifiers, and color themes should match the i3 setup:
  - Modifier: `Mod1` (`Alt`).
  - Window focus: `Alt + h/j/k/l`.
  - Window move: `Shift + Alt + h/j/k/l`.
  - Focus cycle: `Alt + Tab` / `Shift + Alt + Tab`.
  - Tags/Workspaces: 1 to 9 (`Alt + 1..9` to switch, `Shift + Alt + 1..9` to move window).
  - Kill window: `Alt + x`.
  - Fullscreen toggle: `Alt + f`.
  - Floating toggle: `Shift + Alt + f`.
  - Terminal: `Shift + Alt + t` (`wezterm`).
  - File Manager: `Shift + Alt + n` (`nemo`).
  - Launcher: `Alt + q` (`rofi -show drun`).
  - Window switcher: `Alt + e` (`rofi -show window`).
  - Power menu: `Shift + Alt + e` (`rofi-power-menu`).
  - Lock screen: `Ctrl + Alt + l` (`i3lock -c 000000`).
  - Media & Hardware keys: volume via `pactl`, brightness via `brightnessctl`, playback via `playerctl`.
  - Color palette: Catppuccin / eir palette (`bg #070f1c`, `fg #e0d9c7`, `accent #ea6847`).
- Theming and ricing are intentionally deferred to a dedicated step near the end of the plan so base window management functionality is verified first.
- Existing i3 configuration files in `~/.config/i3/` will be kept intact on disk for reference/backup. Unused installed packages (such as `polybar` and `i3-wm` / `dunst` if superseded) can be safely uninstalled once AwesomeWM is verified.

## Design Decisions
- **AwesomeWM Native Substitutions**: Use Awesome's native `wibar` for status bar and `naughty` for notifications rather than running Polybar/Dunst as separate background daemons.
- **Keybinding Parity**: Mirror all i3 keybindings (`Alt+hjkl` navigation, `Shift+Alt+hjkl` container move, `Alt+1..4` tags) to preserve muscle memory.
- **Ricing Separation**: Functional setup (Lua layout, keybindings, autostart, window rules, native notifications) runs first; theme tuning, wallpaper, picom effects, and gap/border aesthetics are handled in a dedicated ricing step.
- **Preserve i3 Dotfiles**: Keep `~/.config/i3` directory on disk untouched even after removing `i3-wm` package.

## Key Sources
- `~/.config/i3/config` — reference keybindings, float rules, media keys, and colors from the i3 setup
- `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/rofi/config.rasi` — base rofi theme config
- `~/.local/bin/rofi-power-menu.sh` — power-menu script called by `Shift+Alt+e`
- `https://awesomewm.org/doc/api/` — AwesomeWM official API documentation for `awful.key`, `awful.wibar`, `gears.wallpaper`, and `naughty`
- `https://github.com/Stardust-kyun/calla` — AwesomeWM reference theme/rice
- `https://github.com/eromatiya/the-glorious-dotfiles` — AwesomeWM reference theme/rice
- `https://github.com/saimoomedits/dotfiles` — AwesomeWM reference theme/rice
- `https://github.com/drahenprofi/dotfiles` — AwesomeWM reference theme/rice
- `https://github.com/ChocolateBread799/dotfiles` — AwesomeWM reference theme/rice
- `https://github.com/Manas140/dotfiles` — AwesomeWM reference theme/rice
- `https://github.com/Crylia/crylia-theme` — AwesomeWM reference theme/rice
- `https://github.com/Mofiqul/awesome-shell` — AwesomeWM reference widgets & shell extensions
- `https://github.com/Alpharivs/dotfiles` — AwesomeWM reference theme/rice
- `https://github.com/Axarva/dotfiles-2.0` - Xomand reference with nice theme and colors

## Proposed Steps

1. **Install AwesomeWM Package** (EXECUTION)
   - Goal: Install `awesome` via pacman and confirm `/usr/share/xsessions/awesome.desktop` is registered for LightDM.
   - Status (Step 1): DONE
   - Approach: Run `sudo pacman -S awesome` and verify that `/usr/share/xsessions/awesome.desktop` exists.

2. **Package & Dependency Cleanup Audit** (INVESTIGATION)
   - Goal: Verify which standalone packages are rendered obsolete by AwesomeWM and safe to remove.
   - Status (Step 2): DONE
   - Approach: Check status of `polybar`, `i3-wm`, `dunst`, `feh`. Confirm that removing `polybar`, `i3-wm`, and `dunst` will not break active utilities (`picom`, `rofi`, `i3lock`, `nm-applet`). Confirm `~/.config/i3/` will be left untouched.
   - Sources: `pacman -Qi polybar i3-wm dunst feh`

3. **Uninstall Redundant Dependencies & Clean Configs** (EXECUTION)
   - Goal: Remove unused packages via pacman.
   - Status (Step 3): DONE
   - Approach: Run `sudo pacman -Rns polybar i3-wm dunst feh` (removing only obsolete packages). Preserve `~/.config/i3` directory and configs intact on disk.

4. **Audit i3 Keybindings & Map to AwesomeWM Lua** (INVESTIGATION)
   - Goal: Produce an exact mapping from `~/.config/i3/config` to Awesome's `awful.key` syntax in `rc.lua`.
   - Status (Step 4): DONE
   - Approach: Translated shortcuts from eir i3 config: `Mod1` (`Alt`), `Alt+hjkl` focus, `Shift+Alt+hjkl` move, `Alt+Tab` cycle, `Alt+1..4` tag switch, `Shift+Alt+1..4` move to tag, `Alt+x` kill window, `Alt+f` fullscreen, `Shift+Alt+f` floating, `Shift+Alt+t` WezTerm, `Shift+Alt+n` Nemo, `Alt+q` Rofi drun, `Alt+e` Rofi window, `Shift+Alt+e` power menu, `Ctrl+Alt+l` lock screen, and Pactl volume keys.
   - Sources: `~/Code/Systems/eir/config/i3/config`

5. **Design Native Wibar & Widgets** (INVESTIGATION)
   - Goal: Determine the functional widget layout for Awesome's native `wibar` to replace Polybar.
   - Status (Step 5): DONE
   - Approach: Design a top `wibar` using Awesome's `awful.widget` components: taglist (1..4), tasklist, clock, systray (for `nm-applet` and Discord), layoutbox, and audio indicator.
   - Sources: AwesomeWM default `rc.lua` template (`/etc/xdg/awesome/rc.lua`)

6. **Write Base AwesomeWM Configuration (`rc.lua`)** (EXECUTION)
   - Goal: Create `~/.config/awesome/rc.lua` with keybindings, autostart entries, and window rules.
   - Status (Step 6): TODO
   - Approach: Copy `/etc/xdg/awesome/rc.lua` to `~/.config/awesome/rc.lua`. Integrate mapped keybindings from Step 4, `wibar` layout from Step 5, autostart execution (`picom`, `nm-applet`), and `awful.rules` for floating dialogs (`Pavucontrol`, `Arandr`, popups).

7. **Configure Native Naughty Notifications** (EXECUTION)
   - Goal: Configure Awesome's built-in `naughty` notification system to handle desktop notifications, replacing `dunst`.
   - Status (Step 7): TODO
   - Approach: Configure `naughty.config` defaults in `rc.lua` (position, default timeout, font, icon dimensions) so `notify-send` and desktop applications (Discord, Firefox) render notifications natively through Awesome.

8. **Verify Base AwesomeWM Session End-to-End** (EXECUTION)
   - Goal: Log into AwesomeWM from LightDM greeter and confirm core window management functionality.
   - Status (Step 8): TODO
   - Approach: Log out of Cinnamon/i3, select AwesomeWM at LightDM, and test: `Alt+hjkl` focus, `Shift+Alt+hjkl` move, `Alt+1..4` tag switching, app launching (`WezTerm`, `Thunar`, `Rofi`), media keys, native `wibar` widgets, system tray, and `naughty` notifications via `notify-send "Test" "Hello"`.

9. **Ricing & Visual Polish Pass** (INVESTIGATION & EXECUTION)
   - Goal: Dedicated pass to customize aesthetics, colors, wallpaper, picom effects, and widget styling.
   - Status (Step 9): TODO
   - Approach:
     - **Theme**: Create `~/.config/awesome/theme.lua` with eir's palette (`#070f1c` background, `#ea6847` accent, `#e0d9c7` foreground, `MesloLGS NF` font).
     - **Wallpaper**: Set background wallpaper (`/usr/share/backgrounds/archlinux/sunset.jpg`) using native `gears.wallpaper`.
     - **Compositor**: Fine-tune `~/.config/picom/picom.conf` for rounded corners, window shadows, and subtle opacity.
     - **Bar Polish**: Style `wibar` tags, borders, and margins for a clean aesthetic.
   - Sources:
     - https://github.com/Stardust-kyun/calla
     - https://github.com/eromatiya/the-glorious-dotfiles
     - https://github.com/saimoomedits/dotfiles
     - https://github.com/drahenprofi/dotfiles
     - https://github.com/ChocolateBread799/dotfiles
     - https://github.com/Manas140/dotfiles
     - https://github.com/Crylia/crylia-theme
     - https://github.com/Mofiqul/awesome-shell
     - https://github.com/Alpharivs/dotfiles
     - https://github.com/Axarva/dotfiles-2.0

## Notes
- `~/.config/i3/` remains intact on disk so you retain your i3 dotfiles if you ever wish to reference or switch back.
- AwesomeWM provides superior native widget capabilities in Lua compared to external status bars like Polybar.
- The plan explicitly defers visual ricing to Step 7, allowing core functionality (navigation, launching, window rules) to be validated first in Step 6.

## History
- **2025-02-14** — Completed Step 5: Design Native Wibar & Widgets
  - Designed native wibar with tags 1..9, layoutbox, tasklist, systray, volume widget, and textclock. Configured position structure so bar position (top/left) can easily be adjusted.
- **2025-02-14** — Completed Step 4: Audit i3 Keybindings & Map to AwesomeWM Lua
  - Extracted shortcuts from eir i3 config (~/Code/Systems/eir/config/i3/config). Mapped Alt+hjkl focus/swap, Alt+1..4 tag switching, Shift+Alt+t (wezterm), Shift+Alt+n (nemo), Alt+q (rofi drun), Alt+x (kill client), and Pactl media keys to AwesomeWM Lua awful.key equivalents.
- **2025-02-14** — Completed Step 3: Uninstall Redundant Dependencies & Clean Configs
  - Uninstalled polybar, i3-wm, dunst via pacman -Rns. Confirmed packages are completely purged.
- **2025-02-14** — Completed Step 2: Package & Dependency Cleanup Audit
  - Audited polybar, i3-wm, dunst, and feh. Confirmed feh is not installed, and polybar, i3-wm, dunst have no dependent reverse packages. Confirmed safe removal won't impact shared utilities (picom, rofi, i3lock, nm-applet) or ~/.config/i3/.
- **2025-02-14** — Completed Step 1: Install AwesomeWM Package
  - Verified awesome package installation, awesome.desktop xsession entry, and default /etc/xdg/awesome/rc.lua template.
