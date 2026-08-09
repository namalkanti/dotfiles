// Loaded from ~/.config/surfingkeys/config.js via "Load settings from" in
// Surfingkeys options (Advanced section).

// Scroll — vim-style ctrl aliases (C-f/b page, C-d/u half)
// u is displaced by history-back remap below; aliased here before that happens
api.map('<ctrl-u>', 'u');
api.map('<ctrl-f>', ' ');
api.map('<ctrl-d>', 'd');
api.mapkey('<ctrl-b>', 'Scroll page up', () => window.scrollBy(0, -window.innerHeight));

//Hints
// gf: opens link in current tab
api.map('gf', 'f');
// f: open link in background tab (gf opens in current tab, vim-style)
api.map('f', 'C');
// F: opens multiple links in background tabs
api.map('F', 'cf');
// sf: opens scroll hints
api.map('sf', ';fs');

// Tabs
// Maps gT to move one tab left
api.map('gT', 'E');
// Maps gt to move one tab right
api.map('gt', 'R');

//History
// Maps u to go back in history
api.map('u', 'S');
// Maps <ctrl-r> to go forward in history
api.map('<ctrl-r>', 'D');
