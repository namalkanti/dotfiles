// Loaded from ~/.config/surfingkeys/config.js via "Load settings from" in
// Surfingkeys options (Advanced section).

// Scroll — vim-style ctrl aliases (C-f/b page, C-d/u half)
// u is displaced by history-back remap below; aliased here before that happens
api.map('U', 'u');
api.map('F', ' ');
api.map('D', 'd');
api.mapkey('B', 'Scroll page up', () => window.scrollBy(0, -window.innerHeight));

//Hints
// gf: opens link in current tab
api.map('gf', 'f');
// f: open link in background tab (gf opens in current tab, vim-style)
api.map('f', 'C');
// sf: opens scroll hints
api.map('sf', ';fs');

// Tabs
// Maps gT to move one tab left
api.map('gT', 'E');
// Maps gt to move one tab right
api.map('gt', 'R');

//Windows
// Temp key for x
api.map('ae', 'w');
// Changes close tab to w
api.map('w', 'x');
// Restore x to switch frame
api.map('x', 'ae');

//History
// Maps u to go back in history
api.map('u', 'S');

