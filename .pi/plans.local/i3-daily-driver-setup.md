# Task: Set up i3 as a daily-driver session on Arch (config content from eir)

**Status**: Draft — Ready for execution

## Context
- User runs Cinnamon on Arch Linux (lightdm) and wants i3 available as a selectable alternate session. Config *content* is sourced from the `eir` NixOS recovery-USB project — reuse the content only, not eir's Nix installation mechanism (flake/modules/`/etc/skel` are NixOS-specific and irrelevant on Arch).
- Arch already has `i3-wm`, `picom`, `polybar`, `rofi`, `i3lock`, `dunst`, `network-manager-applet` installed via pacman. `i3.desktop` and `i3-with-shmlog.desktop` already exist in `/usr/share/xsessions/`, so i3 is already selectable at the lightdm greeter — no package installation or session-file work needed.
- Font mismatch: eir's configs reference the font family `MesloLGS Nerd Font`, but the font actually installed on this machine (`~/.local/share/fonts/MesloLGS NF *.ttf`) registers as `MesloLGS NF`. Left uncorrected, polybar/rofi icons and glyphs likely fail to render.
- Icon theme in use: Papirus (`gsettings get org.cinnamon.desktop.interface icon-theme` → `'Papirus'`). Menu curation (hiding apps without real icons) is done via standard `.desktop` `NoDisplay=true`/`Hidden=true` overrides in `~/.local/share/applications/` — already in place for `vim.desktop` and `claude-code-url-handler.desktop` (the latter set created via Alacarte). Rofi's `drun` mode reads the same directory with the same precedence rules, so this curation carries over to rofi automatically with no extra work.
- Dotfiles-repo tracking of these new configs is explicitly deferred by the user — they land as plain files under `~/.config/` for now, not added to `~/.config/dotfiles`.
- eir's i3 config is a trimmed-down recovery-USB config, not a daily-driver one: it has no fullscreen toggle, no floating toggle, no resize mode, no scratchpad, no split/layout switching, no config reload (only full restart), no i3lock keybind, and no volume/media-key handling anywhere. These are real gaps to fill in, not optional polish.
- eir's autostart wallpaper line (`exec_always ... feh --bg-fill @nixWallpaper@`) uses Nix build-time template placeholders (`@feh@`, `@nixWallpaper@`) that don't resolve outside the Nix build, and `feh` isn't even installed on this box. Theme/wallpaper choice is deferred, so this line should be dropped rather than guessed at.
- Real test apps already installed for verification: Discord (sends notifications, uses a systray icon) and Firefox (sends notifications).
- Karabiner on the user's Mac mirrors this machine's Cinnamon/Mint keybindings, confirmed via `gsettings list-recursively org.cinnamon.desktop.keybindings.wm`. Relevant existing bindings: `push-tile-up/left/right/down` = `Shift+Alt+w/a/s/d`; workspace switch = `Alt+1..4`; move-to-workspace = `Shift+Alt+1..4`; window switch = `Alt+Tab`/`Shift+Alt+Tab`. There is no existing equivalent for "focus adjacent window" since Cinnamon isn't a tiling WM.

## Design Decisions
- **Focus navigation**: `Alt+hjkl`. No prior Cinnamon/Karabiner binding existed for this action, so there was no muscle memory to preserve either way; hjkl was chosen for vim consistency.
- **Move navigation**: `Shift+Alt+wasd`, kept as-is (already applied in eir's config). This matches Cinnamon's `push-tile-*` defaults exactly, preserving existing muscle memory rather than diverging from it.
- **`focus_follows_mouse yes`**: i3 distinguishes real cursor motion from a window-layout change happening under a stationary cursor (workspace switch, alt-tab), and does not steal focus in the latter case — this avoids the Cinnamon/Mutter bug where alt-tabbing near the mouse cursor can yank focus back.
- **Theme/wallpaper**: deferred entirely. Keep eir's current color palette (`bg #070f1c`, `fg #e0d9c7`, `accent #ea6847`, Catppuccin-derived secondaries) as-is. Drop the wallpaper autostart line rather than substituting a guessed replacement.
- **Script location**: `~/.local/bin/rofi-power-menu.sh`, pending the PATH check in Step 1.

## Key Sources
- `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/i3/config` — base i3 config content (colors, gaps, already-updated hjkl-focus/wasd-move nav)
- `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/polybar/config.ini` — base polybar module/color config
- `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/rofi/config.rasi` — base rofi theme config
- `/home/neji49/Drive/Stuffz/Programming/Systems/eir/scripts/rofi-power-menu.sh` — power-menu script to relocate onto this machine
- `~/.config/wezterm/wezterm.lua` — contains the (currently unused) `neofusion_theme` table matching eir's palette; active scheme is `Rosé Pine (Gogh)`. Relevant context for a later theme-alignment pass, not this plan.
- `~/.local/share/applications/*.desktop` — existing manual menu-hiding overrides (`NoDisplay=true`/`Hidden=true`) and general `.desktop` inventory for the icon audit
- `~/.zshrc` — to confirm whether `~/.local/bin` is already on PATH

## Proposed Steps

1. **Confirm script install location** (INVESTIGATION)
   - Goal: Determine whether `~/.local/bin` is already on PATH so `rofi-power-menu.sh` and any future user scripts resolve without a full path.
   - Status (Step 1): TODO
   - Approach: Check `~/.zshrc` (and `~/.zprofile` / `~/.profile` if present) for a PATH export including `~/.local/bin`. If absent, decide whether to add it or reference the script by full path in configs.
   - Sources: `~/.zshrc`

2. **i3 functionality gap audit** (INVESTIGATION)
   - Goal: Produce a concrete list of keybindings/behaviors missing from eir's trimmed-down i3 config that a daily-driver setup needs.
   - Status (Step 2): TODO
   - Approach: Compare eir's `config/i3/config` against i3's standard feature set and this user's needs: fullscreen toggle, floating toggle, resize mode (hjkl-driven), scratchpad, split/layout switching (tabbed/stacked/split), config reload (distinct from full restart), exit binding, `for_window` floating-exception rules for apps that misbehave when tiled (file picker dialogs, `pavucontrol`, video-call windows), volume/brightness media-key bindings (e.g. via `pactl`), and an `i3lock` keybind. Output a finalized keybind list to apply in Step 3.
   - Sources: `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/i3/config`, i3 user guide default keybindings

3. **Write base i3 config** (EXECUTION)
   - Goal: Produce a working `~/.config/i3/config`.
   - Status (Step 3): TODO
   - Approach: Start from eir's `config/i3/config`. Fix the font line to `MesloLGS NF`. Add `focus_follows_mouse yes`. Add `exec --no-startup-id dunst` to autostart. Remove the Nix-templated wallpaper `exec_always` line entirely. Update the `rofi-power-menu` references to the resolved path from Step 1. Fold in every binding identified in Step 2 (fullscreen, float toggle, resize mode, scratchpad, layout switching, reload, exit, `for_window` rules, media keys, i3lock keybind).

4. **Polybar module audit** (INVESTIGATION)
   - Goal: Decide what module changes eir's polybar config needs for daily use.
   - Status (Step 4): TODO
   - Approach: eir's bar currently has `xworkspaces`, `date`, `memory`, `cpu`, `disk`, `wlan`, `battery`, `powermenu`, `tray` — with no volume/audio module. Decide whether to add a `pulseaudio` (or `alsa`) module, whether the bar position (top) is fine, and whether any existing module should be dropped for a laptop-vs-desktop mismatch (e.g. `battery`/`wlan` if this machine has neither).
   - Sources: `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/polybar/config.ini`, `polybar --list-monitors` / hardware check for battery+wireless presence

5. **Write polybar config** (EXECUTION)
   - Goal: Produce a working `~/.config/polybar/config.ini`.
   - Status (Step 5): TODO
   - Approach: Start from eir's `config/polybar/config.ini`. Fix the font line to `MesloLGS NF`. Fix the `rofi-power-menu` click-action path from Step 1. Apply the module additions/removals decided in Step 4.

6. **Rofi styling + icon audit** (INVESTIGATION)
   - Goal: Confirm what rofi needs to visually match the curated Cinnamon menu.
   - Status (Step 6): TODO
   - Approach: Confirm whether `icon-theme: "Papirus"` must be set explicitly in the rasi config (rofi does not reliably inherit the GTK icon theme automatically). Launch `rofi -show drun` and note any installed, visible (`NoDisplay` != true) apps that render without a usable icon.
   - Sources: `/home/neji49/Drive/Stuffz/Programming/Systems/eir/config/rofi/config.rasi`, `~/.local/share/applications/*.desktop`, `/usr/share/applications/*.desktop`

7. **Write rofi config** (EXECUTION)
   - Goal: Produce a working `~/.config/rofi/config.rasi`.
   - Status (Step 7): TODO
   - Approach: Start from eir's `config/rofi/config.rasi`. Fix the font line to `MesloLGS NF`. Set `icon-theme: "Papirus"`. Apply any additional styling decided in Step 6.

8. **Fill in missing app icons** (EXECUTION)
   - Goal: Any app found in Step 6 rendering without a usable icon gets a corrected local `.desktop` entry.
   - Status (Step 8): TODO
   - Approach: For each such app, copy its system `.desktop` file into `~/.local/share/applications/`, and edit the `Icon=` line to point at a resolvable icon name or absolute image path. Document this as the repeatable technique for handling future icon-less apps (mirrors how `vim.desktop`/`claude-code-url-handler.desktop` overrides already work for hiding entries).

9. **Relocate power-menu script** (EXECUTION)
   - Goal: `rofi-power-menu.sh` is runnable from wherever the i3/polybar configs reference it.
   - Status (Step 9): TODO
   - Approach: Copy `/home/neji49/Drive/Stuffz/Programming/Systems/eir/scripts/rofi-power-menu.sh` to `~/.local/bin/rofi-power-menu.sh` (per Step 1's PATH decision) and `chmod +x` it.

10. **Verify the full session** (EXECUTION)
    - Goal: Confirm the assembled i3 session actually works end-to-end.
    - Status (Step 10): TODO
    - Approach: Log out of Cinnamon, select i3 (or i3-with-shmlog) at the lightdm greeter, log in. Exercise every keybind category: focus (`Alt+hjkl`), move (`Shift+Alt+wasd`), fullscreen toggle, floating toggle, resize mode, scratchpad, layout switching, config reload, exit, i3lock, power menu (`rofi-power-menu`), volume/media keys. Confirm polybar renders with the correct font and all Step 4 modules. Trigger a real notification from both Discord and Firefox to confirm `dunst` actually surfaces app notifications, not just synthetic `notify-send` tests. Confirm Discord's tray icon and `nm-applet` both render correctly in polybar's `tray` module. Confirm rofi's `drun` icon coverage visually matches the curated Cinnamon menu (respecting the existing `NoDisplay`/`Hidden` overrides).

## Notes
- eir's NixOS installation mechanism (flake, modules, `/etc/skel` provisioning, systemd activation ordering) is explicitly out of scope — this plan only reuses eir's config *file content*.
- Dotfiles-repo integration of these new configs (`~/.config/i3`, `~/.config/polybar`, `~/.config/rofi`, `~/.local/bin/rofi-power-menu.sh`) is deferred to a later manual pass; the user will handle that themselves.
- Theme/wallpaper alignment with wezterm's active `Rosé Pine (Gogh)` scheme (or reactivating the shelved `neofusion_theme`) is a separate future task, not part of this plan.
- The i3lock keybind and any resize-mode/scratchpad key choices from Step 2 are open until that investigation step runs — no keys are pre-selected in this plan beyond what's already fixed (focus/move nav).
