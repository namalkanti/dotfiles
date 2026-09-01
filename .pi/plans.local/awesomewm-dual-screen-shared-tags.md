# Task: Add isolated dual-screen shared tags to the AwesomeWM configuration

**Status**: Draft — Ready for execution

## Context
The AwesomeWM configuration is shared by a single-screen laptop and a dual-monitor desktop. The single-screen experience is stable and must remain isolated from the shared-tag implementation. Shared tags should activate only when exactly two screens are present at Awesome startup; one-screen and three-or-more-screen startup must retain vanilla per-screen tags. Runtime topology mode changes are out of scope.

AwesomeWM 4.3 is installed. A vendored `sharedtags` module exists at `~/.config/awesome/sharedtags/init.lua`. Prior integration was disabled after workspace order changed as tags moved between screens. The current `keys.lua` still imports `sharedtags` unconditionally with `pcall`, while `rc.lua` has commented-out shared-tag initialization and `wibar.lua` creates vanilla tags when a screen has none.

In dual-screen mode, both bars must list the same stable sequence of tags 1–9. Tag 1 starts selected on screen 1, tag 2 starts selected on screen 2, and tags 3–9 initially belong to screen 1 without being selected. Selecting a tag already displayed on the other screen swaps it with the current screen's selected tag. Selecting an unselected tag owned by the other screen pulls it to the current screen without changing what the other screen displays. `Alt+s` swaps the two displayed tags.

A small corner marker should indicate that an unselected tag belongs to the monitor whose bar is being rendered. The normal selected background remains the displayed-here indication, and the existing dot remains the client-occupancy indication. No ownership marker should appear in vanilla mode.

Awesome's stock taglist accepts a custom `source`, allowing each dual-screen taglist to use the stable global tag array rather than mutable `screen.tags` order. Its internal signal dispatcher normally refreshes only the list for `tag.screen`, however, so global taglists require explicit cross-screen refresh handling.

Moving a selected tag can synchronously leave its old screen temporarily unselected and invoke fallback behavior; Lua tag mutations are not transactional. Dual-screen operations must capture intended selections, restore explicit selections after movement, and defensively enforce that both screens have selected tags. This guard belongs only to the shared dual-screen path.

## Design Decisions
- **Startup-only mode selection**: Evaluate the screen count once during Awesome startup. Exactly two screens use shared tags; all other counts use vanilla per-screen tags. Live migration between modes is intentionally unsupported.
- **Strict single-screen isolation**: Do not import, initialize, or reference the sharedtags module from the vanilla path. Pass an explicit mode/context into dependent modules instead of allowing each module to detect sharedtags independently.
- **Initial dual-screen distribution**: Screen 1 displays tag 1, screen 2 displays tag 2, and tags 3–9 initially reside on screen 1.
- **Stable global ordering**: In dual-screen mode, render taglists from the global tag array and its immutable shared tag identity, never from mutable screen-local indices.
- **Conditional swap semantics**: Swap only when the requested tag is selected on the other monitor. Pull an unselected remotely owned tag without disturbing that monitor's displayed tag.
- **Explicit postcondition**: After every shared pull or swap, explicitly select the intended tag on each affected screen and verify neither screen lacks a selected tag. Restore captured intended selections if necessary rather than accepting an arbitrary fallback.
- **Three-plus screens**: Preserve vanilla per-screen behavior because that topology will not be tested presently.

## Key Sources
- `/home/neji49/.config/awesome/rc.lua` — Startup orchestration and currently disabled sharedtags setup.
- `/home/neji49/.config/awesome/keys.lua` — Unconditional sharedtags import, numeric tag bindings, disabled `Alt+s`, and vanilla/shared conditional branches.
- `/home/neji49/.config/awesome/wibar.lua` — Per-screen tag creation, taglist source/template, occupancy dot, and mouse bindings.
- `/home/neji49/.config/awesome/sharedtags/init.lua` — Vendored tag creation, movement, fallback, sorting, view, and screen-removal behavior.
- `/home/neji49/.config/awesome/sharedtags/README.md` — Integration guidance and documented cross-screen/X-server constraints.
- `/usr/share/awesome/lib/awful/widget/taglist.lua` — Installed Awesome 4.3 taglist source and screen-local signal refresh implementation.
- `/usr/share/awesome/lib/awful/tag.lua` — Installed Awesome 4.3 tag movement, selection, history, and fallback contracts.

## Proposed Steps
1. **Confirm installed Awesome tag movement and taglist contracts** (INVESTIGATION)
   - Goal: Establish the exact synchronous behavior and safe mutation order before implementing shared pull/swap operations.
   - Status (Step 1): TODO
   - Approach: Trace installed Awesome 4.3 source and the vendored sharedtags implementation for `tag.screen` assignment, selected-tag changes, fallback selection, tag history, index mutation, emitted signals, and taglist updates. Determine how to capture both selected tags, move tags without relying on arbitrary fallback, explicitly restore intended views, and verify the two-screen selected-tag invariant. Identify all signals needed to refresh both global taglists for ownership, selection, occupancy, urgency, name, and client movement changes.
   - Sources: `/usr/share/awesome/lib/awful/tag.lua`, `/usr/share/awesome/lib/awful/widget/taglist.lua`, `/home/neji49/.config/awesome/sharedtags/init.lua`, and `/home/neji49/.config/awesome/sharedtags/README.md`.

2. **Introduce isolated startup-only tag mode selection** (EXECUTION)
   - Goal: Ensure sharedtags code can affect the configuration only when exactly two screens were detected at startup.
   - Status (Step 2): TODO
   - Approach: In startup orchestration, evaluate `screen.count()` once and construct an explicit tag context describing either vanilla or dual-shared mode. Require and initialize `sharedtags` only inside the exactly-two-screen branch. Remove the unconditional `pcall(require, "sharedtags")` from `keys.lua`. Inject the context into keys and wibar initialization so those modules do not independently import or infer shared mode. Keep one-screen and three-plus paths on existing vanilla tag creation and behavior. Do not add live topology migration.

3. **Initialize deterministic dual-screen shared tags** (EXECUTION)
   - Goal: Create one globally identified set of tags with predictable initial ownership and selection.
   - Status (Step 3): TODO
   - Approach: Create shared tags 1–9 in a stable global array. Assign tag 1 to screen 1 and tag 2 to screen 2 so each becomes that screen's initial selected tag; initially assign tags 3–9 to screen 1 without selecting them. Preserve immutable global numeric identity through existing `sharedtagindex` metadata or an equivalent explicit field. Prevent `wibar.lua` from creating duplicate per-screen tags in shared mode while leaving vanilla creation unchanged.

4. **Centralize dual-screen pull, conditional swap, and invariant enforcement** (EXECUTION)
   - Goal: Provide one authoritative implementation of workspace selection semantics.
   - Status (Step 4): TODO
   - Approach: Add a focused helper/module operating only on the injected dual-screen context. For a requested tag: view it normally when already local; pull and display it when it is unselected on the other screen while preserving that screen's selected tag; swap it with the current screen's selected tag when it is displayed on the other screen. Add a reusable primitive for swapping the two screens' selected tags. Capture intended selections before movement, account for synchronous fallback behavior identified in Step 1, explicitly `view_only()` the intended tags after movement, update history as required by the installed API, and enforce the postcondition that both screens have a selected tag. If a postcondition fails, restore the captured intended tag rather than accepting `awful.tag.find_fallback()` selection. Keep these guards out of vanilla mode.

5. **Wire keyboard and taglist mouse behavior through the active mode** (EXECUTION)
   - Goal: Make all user entry points obey identical shared-tag semantics without changing vanilla controls.
   - Status (Step 5): TODO
   - Approach: Route dual-mode number-key viewing and taglist left-click through the centralized selection helper. Restore `Alt+s` using the same selected-tag swap primitive and make it unavailable or a harmless no-op outside dual mode. Preserve vanilla number-key and taglist behavior verbatim. Review move-to-tag, client multi-tag, view-toggle, right-click, and scroll bindings against Awesome's documented cross-screen constraints; either route shared operations through safe context helpers or retain only behavior that cannot violate ownership/selection invariants. Keep existing key descriptions accurate.

6. **Render stable global taglists with monitor-ownership markers** (EXECUTION)
   - Goal: Show tags 1–9 in fixed order on both bars and communicate ownership, visibility, and occupancy independently.
   - Status (Step 6): TODO
   - Approach: In dual mode, configure each taglist's custom `source` to return the stable global shared-tag array, ordered by immutable global identity rather than `tag.index` or `screen.tags`. Retain the normal selected background for the tag displayed on its owning monitor and retain the existing occupancy dot for tags containing clients. Add a small Awesome-style corner marker only when a tag belongs to the bar's screen but is not selected there. Do not create or show this marker in vanilla mode. Add explicit refresh propagation so both screen taglists update when tag ownership, selection, client occupancy, urgency, naming, or relevant client-screen/tag associations change; ensure signal connections have an intentional lifetime matching Awesome's configuration process.

7. **Validate vanilla isolation and dual-screen invariants** (EXECUTION)
   - Goal: Demonstrate that the laptop path remains unchanged and the dual-screen behavior is coherent.
   - Status (Step 7): TODO
   - Approach: Run Awesome's configuration syntax check and any available Lua static checks. Trace module loading and branches to prove sharedtags is not imported or initialized for one screen or three-plus screens. Validate that vanilla per-screen tag creation, keyboard controls, taglist mouse controls, ordering, and visual appearance are unchanged. For two screens, validate initial 1/2 selection, fixed 1–9 ordering on both bars, local selection, remote-unselected pull, remote-selected swap, repeated swaps, `Alt+s`, ownership corner markers, occupancy dots, and cross-screen taglist refresh. Exercise every pull/swap branch and assert after each operation that both screens have a selected tag. Record any checks that require restarting Awesome on a physical dual-monitor session and provide a concise manual test sequence for them.

## Notes
- The previous ordering issue is consistent with `sharedtags.movetag()` rewriting mutable screen-local `tag.index`; the global taglist must not use that value for presentation order.
- A completed pull or conditional swap logically cannot leave a screen without a displayed tag. The defensive postcondition exists because intermediate `tag.screen` mutations emit signals synchronously and can trigger fallback behavior before the logical operation completes.
- Single-screen isolation is the primary compatibility constraint. Avoid shared helper calls, shared metadata assumptions, extra indicators, or changed input behavior in vanilla mode.
- Runtime monitor hotplug may change physical screens while Awesome is running, but changing between vanilla and shared modes without an Awesome restart is explicitly outside this plan.
