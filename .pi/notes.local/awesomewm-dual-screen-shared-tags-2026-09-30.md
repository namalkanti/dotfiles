# AwesomeWM Dual-Screen Shared Tags — SHELVED (Full Plan Preserved for Resurrection)

**Type**: Exploration / Feature (never executed)
**Started**: 2026-09-01 (plan drafted)
**Completed**: 2026-09-30 (shelved)
**Status**: Shelved — never executed; current vanilla per-screen setup deemed acceptable
**Value**: High — full implementation plan preserved; resurrect as-is if multi-monitor workflow becomes a real pain point or a Wayland decision forces the issue

## SUMMARY
A complete, execution-ready plan for adding isolated dual-screen shared tags to the AwesomeWM config was drafted after a prior naive sharedtags integration failed (tag ordering on the bars shuffled when tags moved between screens, because `sharedtags.movetag()` rewrites mutable screen-local `tag.index`). The plan was evaluated and shelved without execution: the current per-screen setup turned out not to be annoying enough in practice to justify a weekend of work whose riskiest piece (custom taglist `source` + cross-screen refresh, Step 6) is exactly the piece that would not survive a Wayland transition. All dead sharedtags branches were subsequently removed from the config. The full plan text, difficulty assessment, and Wayland analysis are preserved below for resurrection.
[END_SUMMARY]

## KEY_DECISIONS
- **Decision**: Shelve the plan entirely rather than execute full or reduced scope.
  - Rationale: user tried the existing per-screen setup and found it acceptable ("can't say it's that annoying now that I've tried it"). Cheapest fix is no fix.
- **Decision**: Wayland timeline estimated at 1–2 years — too soon for the full plan's risky parts, too far to suffer a broken multi-monitor workflow. This middle case is what killed Step 6 specifically.
- **Decision**: Remove all dead sharedtags code paths from `keys.lua` and `rc.lua` so the config doesn't imply an integration that doesn't exist. The vendored `~/.config/awesome/sharedtags/` module directory was **kept** on disk (dormant, unreferenced) to ease resurrection.
- **Decision**: Keep this note maximally detailed — it is the resurrection kit. The plan below is verbatim-complete.
[END_KEY_DECISIONS]

## KEY_LEARNINGS
- **Root cause of the previous failed integration**: `sharedtags.movetag()` rewrites mutable screen-local `tag.index`. Any taglist rendering order derived from `tag.index` or `screen.tags` will shuffle when tags move between screens. Presentation order must come from a stable global tag array with immutable identity metadata (e.g. `sharedtagindex`).
- **Awesome 4.3 `awful.widget.taglist` refreshes only the list for `tag.screen`** in its internal signal dispatcher. Global (both-bars-show-all-tags) taglists require explicit cross-screen refresh plumbing — this is the single hardest, most debug-expensive, most upgrade-fragile part of the whole plan.
- **Lua tag mutations are not transactional**: setting `tag.screen` emits signals synchronously and can trigger `awful.tag.find_fallback()` selection before the logical operation completes. Correct pattern: capture intended selections → move → explicit `view_only()` restore → assert both screens have a selected tag → restore captured intent on failure, never accept arbitrary fallback.
- **Portability profile under a Wayland transition**: standard `awful` API usage (mode gating, tag creation, `sharedtags.viewonly` calls, key routing = plan Steps 2–5) ports conceptually; hacks against taglist widget internals (Step 6) do not. If resurrecting near a Wayland decision, do Steps 2–5 only.
- **somewm** (AUR `somewm-git`, github.com/trip-zip/somewm, first packaged ~2026-01): AwesomeWM ported to Wayland, claims 100% Lua API compatibility, GPL-3. Young project, unknown longevity, deviations documented in its DEVIATIONS.md (systray via SNI/D-Bus instead of X embed, inset titlebar borders, etc.). Worth re-checking maturity if Wayland timeline firmens.
- **niri's workspace model** (workspaces not pinned to monitors, movable on demand) natively provides ~80% of the shared-tags semantics — relevant if a Wayland switch goes to niri instead of somewm, in which case this plan's value drops to its design-decision rationale only.
- Effort estimate if resurrected: Step 1 investigation 2–4h (trace `/usr/share/awesome/lib/awful/tag.lua`, `awful/widget/taglist.lua`, vendored sharedtags); Steps 2–5 roughly an evening each; Step 6 a weekend with a tail. Testing dominates: requires physically sitting at the dual-monitor machine and restarting Awesome; slow iteration loop.
[END_KEY_LEARNINGS]

## Why It Was Shelved (Decision Record)

1. The plan was evaluated as well-scoped and technically sound — difficulty moderate, not huge (~250–400 lines across `rc.lua`/`keys.lua`/`wibar.lua` plus one helper module). The shelving was not a quality judgment on the plan.
2. Difficulty ranking of the steps (most → least painful):
   - **Step 6** (global taglist source + cross-screen refresh + ownership markers): the hard one; fighting stock taglist internals.
   - **Step 4** (pull/swap invariants against non-transactional mutations): moderately hard but tractable; correct pattern identified (see learnings).
   - **Steps 2/3/5** (mode gating, tag init, binding routing): mechanical; `keys.lua` already had half-wired `has_sharedtags` branches.
   - Corner marker alone (widget_template `update_callback`): easy — could be added standalone without Steps 1/6 machinery if visual polish is ever wanted cheaply.
3. Wayland consideration: user believes gaps remain now (transition unlikely <1 year) but also unlikely to hold off >2 years. Step 6's taglist-internals hack is the part that dies on transition; Steps 2–5 survive. A reduced-scope variant (Steps 2–4 + `Alt+s` + number-key routing via `sharedtags.viewonly`, stock taglist rendering accepted, no markers) was proposed as ~20% of effort for ~80% of functional value — but see next point.
4. Deciding factor: living with the existing vanilla per-screen setup proved not annoying enough to justify even the reduced scope. Behavioral tradeoff of reduced scope understood and accepted as moot: number keys would still map to stable global identity, but bar tag order would shuffle visually on moves (loses Step 6 item 1).
5. Post-shelving cleanup executed 2026-09-30: removed sharedtags `pcall` import, `st_mod` init parameter, disabled `Alt+s` block, and all `has_sharedtags and tags` conditional branches from `keys.lua`; removed commented-out sharedtags init block from `rc.lua`; reworded the sharedtags-referencing comment at the per-screen tag creation guard in `wibar.lua` (guard kept — it also protects against duplicate tags on screen hotplug reconnect). Config behavior unchanged (all removed branches were dead code: `tags` was never passed, so every conditional took the vanilla path).

## The Full Plan (Verbatim — Resurrection Kit)

### Task
Add isolated dual-screen shared tags to the AwesomeWM configuration.

### Context
The AwesomeWM configuration is shared by a single-screen laptop and a dual-monitor desktop. The single-screen experience is stable and must remain isolated from the shared-tag implementation. Shared tags should activate only when exactly two screens are present at Awesome startup; one-screen and three-or-more-screen startup must retain vanilla per-screen tags. Runtime topology mode changes are out of scope.

AwesomeWM 4.3 is installed. A vendored `sharedtags` module exists at `~/.config/awesome/sharedtags/init.lua`. Prior integration was disabled after workspace order changed as tags moved between screens. The current `keys.lua` still imports `sharedtags` unconditionally with `pcall`, while `rc.lua` has commented-out shared-tag initialization and `wibar.lua` creates vanilla tags when a screen has none. *(Note: as of the 2026-09-30 cleanup, the keys.lua import and rc.lua commented block no longer exist — resurrection means re-adding them per Steps 2–3 below.)*

In dual-screen mode, both bars must list the same stable sequence of tags 1–9. Tag 1 starts selected on screen 1, tag 2 starts selected on screen 2, and tags 3–9 initially belong to screen 1 without being selected. Selecting a tag already displayed on the other screen swaps it with the current screen's selected tag. Selecting an unselected tag owned by the other screen pulls it to the current screen without changing what the other screen displays. `Alt+s` swaps the two displayed tags.

A small corner marker should indicate that an unselected tag belongs to the monitor whose bar is being rendered. The normal selected background remains the displayed-here indication, and the existing dot remains the client-occupancy indication. No ownership marker should appear in vanilla mode.

Awesome's stock taglist accepts a custom `source`, allowing each dual-screen taglist to use the stable global tag array rather than mutable `screen.tags` order. Its internal signal dispatcher normally refreshes only the list for `tag.screen`, however, so global taglists require explicit cross-screen refresh handling.

Moving a selected tag can synchronously leave its old screen temporarily unselected and invoke fallback behavior; Lua tag mutations are not transactional. Dual-screen operations must capture intended selections, restore explicit selections after movement, and defensively enforce that both screens have selected tags. This guard belongs only to the shared dual-screen path.

### Design Decisions
- **Startup-only mode selection**: Evaluate the screen count once during Awesome startup. Exactly two screens use shared tags; all other counts use vanilla per-screen tags. Live migration between modes is intentionally unsupported.
- **Strict single-screen isolation**: Do not import, initialize, or reference the sharedtags module from the vanilla path. Pass an explicit mode/context into dependent modules instead of allowing each module to detect sharedtags independently.
- **Initial dual-screen distribution**: Screen 1 displays tag 1, screen 2 displays tag 2, and tags 3–9 initially reside on screen 1.
- **Stable global ordering**: In dual-screen mode, render taglists from the global tag array and its immutable shared tag identity, never from mutable screen-local indices.
- **Conditional swap semantics**: Swap only when the requested tag is selected on the other monitor. Pull an unselected remotely owned tag without disturbing that monitor's displayed tag.
- **Explicit postcondition**: After every shared pull or swap, explicitly select the intended tag on each affected screen and verify neither screen lacks a selected tag. Restore captured intended selections if necessary rather than accepting an arbitrary fallback.
- **Three-plus screens**: Preserve vanilla per-screen behavior because that topology will not be tested presently.

### Key Sources
- `/home/neji49/.config/awesome/rc.lua` — Startup orchestration (sharedtags setup removed 2026-09-30; re-add per Step 2).
- `/home/neji49/.config/awesome/keys.lua` — Numeric tag bindings; sharedtags branches removed 2026-09-30 (previously: unconditional pcall import, disabled `Alt+s`, vanilla/shared conditional branches).
- `/home/neji49/.config/awesome/wibar.lua` — Per-screen tag creation (guarded), taglist source/template, occupancy dot, mouse bindings.
- `/home/neji49/.config/awesome/sharedtags/init.lua` — Vendored module (217 lines): tag creation, movement, fallback, sorting, view, screen-removal behavior. Still on disk.
- `/home/neji49/.config/awesome/sharedtags/README.md` — Integration guidance and documented cross-screen/X-server constraints; ships `rc.lua.patch`.
- `/usr/share/awesome/lib/awful/widget/taglist.lua` — Installed Awesome 4.3 taglist source and screen-local signal refresh implementation.
- `/usr/share/awesome/lib/awful/tag.lua` — Installed Awesome 4.3 tag movement, selection, history, and fallback contracts.

### Proposed Steps
1. **Confirm installed Awesome tag movement and taglist contracts** (INVESTIGATION)
   - Goal: Establish the exact synchronous behavior and safe mutation order before implementing shared pull/swap operations.
   - Approach: Trace installed Awesome 4.3 source and the vendored sharedtags implementation for `tag.screen` assignment, selected-tag changes, fallback selection, tag history, index mutation, emitted signals, and taglist updates. Determine how to capture both selected tags, move tags without relying on arbitrary fallback, explicitly restore intended views, and verify the two-screen selected-tag invariant. Identify all signals needed to refresh both global taglists for ownership, selection, occupancy, urgency, name, and client movement changes.
   - Sources: `/usr/share/awesome/lib/awful/tag.lua`, `/usr/share/awesome/lib/awful/widget/taglist.lua`, `sharedtags/init.lua`, `sharedtags/README.md`.

2. **Introduce isolated startup-only tag mode selection** (EXECUTION)
   - Goal: Ensure sharedtags code can affect the configuration only when exactly two screens were detected at startup.
   - Approach: In startup orchestration, evaluate `screen.count()` once and construct an explicit tag context describing either vanilla or dual-shared mode. Require and initialize `sharedtags` only inside the exactly-two-screen branch. Remove the unconditional `pcall(require, "sharedtags")` from `keys.lua`. Inject the context into keys and wibar initialization so those modules do not independently import or infer shared mode. Keep one-screen and three-plus paths on existing vanilla tag creation and behavior. Do not add live topology migration.

3. **Initialize deterministic dual-screen shared tags** (EXECUTION)
   - Goal: Create one globally identified set of tags with predictable initial ownership and selection.
   - Approach: Create shared tags 1–9 in a stable global array. Assign tag 1 to screen 1 and tag 2 to screen 2 so each becomes that screen's initial selected tag; initially assign tags 3–9 to screen 1 without selecting them. Preserve immutable global numeric identity through existing `sharedtagindex` metadata or an equivalent explicit field. Prevent `wibar.lua` from creating duplicate per-screen tags in shared mode while leaving vanilla creation unchanged.

4. **Centralize dual-screen pull, conditional swap, and invariant enforcement** (EXECUTION)
   - Goal: Provide one authoritative implementation of workspace selection semantics.
   - Approach: Add a focused helper/module operating only on the injected dual-screen context. For a requested tag: view it normally when already local; pull and display it when it is unselected on the other screen while preserving that screen's selected tag; swap it with the current screen's selected tag when it is displayed on the other screen. Add a reusable primitive for swapping the two screens' selected tags. Capture intended selections before movement, account for synchronous fallback behavior identified in Step 1, explicitly `view_only()` the intended tags after movement, update history as required by the installed API, and enforce the postcondition that both screens have a selected tag. If a postcondition fails, restore the captured intended tag rather than accepting `awful.tag.find_fallback()` selection. Keep these guards out of vanilla mode.

5. **Wire keyboard and taglist mouse behavior through the active mode** (EXECUTION)
   - Goal: Make all user entry points obey identical shared-tag semantics without changing vanilla controls.
   - Approach: Route dual-mode number-key viewing and taglist left-click through the centralized selection helper. Restore `Alt+s` using the same selected-tag swap primitive and make it unavailable or a harmless no-op outside dual mode. Preserve vanilla number-key and taglist behavior verbatim. Review move-to-tag, client multi-tag, view-toggle, right-click, and scroll bindings against Awesome's documented cross-screen constraints; either route shared operations through safe context helpers or retain only behavior that cannot violate ownership/selection invariants. Keep existing key descriptions accurate.

6. **Render stable global taglists with monitor-ownership markers** (EXECUTION) — *highest risk; defer or drop if resurrecting near a Wayland decision*
   - Goal: Show tags 1–9 in fixed order on both bars and communicate ownership, visibility, and occupancy independently.
   - Approach: In dual mode, configure each taglist's custom `source` to return the stable global shared-tag array, ordered by immutable global identity rather than `tag.index` or `screen.tags`. Retain the normal selected background for the tag displayed on its owning monitor and retain the existing occupancy dot for tags containing clients. Add a small Awesome-style corner marker only when a tag belongs to the bar's screen but is not selected there. Do not create or show this marker in vanilla mode. Add explicit refresh propagation so both screen taglists update when tag ownership, selection, client occupancy, urgency, naming, or relevant client-screen/tag associations change; ensure signal connections have an intentional lifetime matching Awesome's configuration process.

7. **Validate vanilla isolation and dual-screen invariants** (EXECUTION)
   - Goal: Demonstrate that the laptop path remains unchanged and the dual-screen behavior is coherent.
   - Approach: Run Awesome's configuration syntax check (`awesome -k`) and any available Lua static checks (luacheck). Trace module loading and branches to prove sharedtags is not imported or initialized for one screen or three-plus screens. Validate that vanilla per-screen tag creation, keyboard controls, taglist mouse controls, ordering, and visual appearance are unchanged. For two screens, validate initial 1/2 selection, fixed 1–9 ordering on both bars, local selection, remote-unselected pull, remote-selected swap, repeated swaps, `Alt+s`, ownership corner markers, occupancy dots, and cross-screen taglist refresh. Exercise every pull/swap branch and assert after each operation that both screens have a selected tag. Record any checks that require restarting Awesome on a physical dual-monitor session and provide a concise manual test sequence for them.

### Plan Notes
- The previous ordering issue is consistent with `sharedtags.movetag()` rewriting mutable screen-local `tag.index`; the global taglist must not use that value for presentation order.
- A completed pull or conditional swap logically cannot leave a screen without a displayed tag. The defensive postcondition exists because intermediate `tag.screen` mutations emit signals synchronously and can trigger fallback behavior before the logical operation completes.
- Single-screen isolation is the primary compatibility constraint. Avoid shared helper calls, shared metadata assumptions, extra indicators, or changed input behavior in vanilla mode.
- Runtime monitor hotplug may change physical screens while Awesome is running, but changing between vanilla and shared modes without an Awesome restart is explicitly outside this plan.

## Reduced-Scope Variant (If Resurrecting Under Wayland Uncertainty)
Do Steps 1–4 plus `Alt+s` and number-key routing via `sharedtags.viewonly`. Skip Step 6 entirely (custom source, markers, refresh plumbing) and trim Step 5 to keyboard-only routing; accept stock per-screen taglist rendering.
- Cost: ~20% of full effort (evening or two vs weekend-with-tail).
- Value: correct pull/swap/move semantics; number keys map to stable global identity.
- Accepted tradeoff: bar tag order may shuffle visually when tags move (no stable-order source); no ownership marker (which monitor owns a tag is only inferable from selection + occupancy).
- Portability: all standard `awful` API; best chance of surviving somewm. Step 6 remains additive later — Steps 2–3's stable global array and immutable identity are exactly its foundation.

## Wayland Landscape Snapshot (as of 2026-09-30)
- Upstream Awesome: X11-only; Wayland backend question (awesomeWM/awesome#3621) closed as wait-and-see; no progress.
- somewm (trip-zip): Wayland port, claims 100% Lua API compat; on AUR since ~2026-01; young; deviations doc at github.com/trip-zip/somewm/blob/main/DEVIATIONS.md.
- niri: workspace model natively close to shared-tags semantics; if Wayland switch goes here, only the plan's design rationale is relevant, not the code.
- Historical Wayland gaps (screen sharing, gamma, systray, fractional scaling) largely closed via portals/compositor maturity; remaining blockers tend to be niche (X11 screen-scraping, remote X, anti-cheat, exotic input remapping).

## Critical Files
- `/home/neji49/.config/awesome/rc.lua` — startup orchestration; sharedtags init block removed, `keys.init(modkey, terminal, filemanager)` is the plain signature.
- `/home/neji49/.config/awesome/keys.lua` — all keybindings; sharedtags branches removed 2026-09-30; tag loop (1–9) is pure vanilla `screen.tags[i]` paths.
- `/home/neji49/.config/awesome/wibar.lua` — per-screen bars; tag creation guard (`if not s.tags or #s.tags == 0`) kept for hotplug-reconnect safety; occupancy dot and taglist template live here.
- `/home/neji49/.config/awesome/sharedtags/` — vendored module, dormant on disk, unreferenced by config. Delete only if resurrecting via a different mechanism.
- `/usr/share/awesome/lib/awful/tag.lua`, `/usr/share/awesome/lib/awful/widget/taglist.lua` — installed 4.3 contracts Step 1 must trace.

## History Highlights
- ~2025 or earlier: first naive sharedtags integration attempted; disabled after tag order shuffled on moves (root cause later identified: `tag.index` rewriting).
- 2026-09-01: full 7-step plan drafted to `.pi/plans.local/awesomewm-dual-screen-shared-tags.md` (never executed; all steps remained TODO).
- 2026-09-30: plan evaluated for difficulty and Wayland exposure → shelved; dead sharedtags code removed from config; this note written as the resurrection kit.

## Future Considerations
- Resurrection triggers: multi-monitor workflow becomes a real pain point; or Wayland decision firmens (then do reduced-scope variant, or evaluate somewm/niri instead).
- Cheap standalone win available without the full plan: ownership corner marker only, via taglist `widget_template` `update_callback` — no custom source, no refresh plumbing.
- If somewm matures: re-verify the taglist signal-dispatch assumption (`tag.screen`-local refresh) against its implementation before building Step 6 on it.
- Consider git-init'ing `~/.config/awesome` — config is currently unversioned; cleanup on 2026-09-30 was done with manual `.bak` files instead of diff review.
