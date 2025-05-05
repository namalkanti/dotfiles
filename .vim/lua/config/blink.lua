-- lua/config/blink.lua
local M = {}

function M.setup()
  local ok, cmp = pcall(require, "blink.cmp")
  if not ok then
    vim.notify("blink.cmp not found!", vim.log.levels.ERROR)
    return
  end

  cmp.setup({
    sources = {
      default = {"codecompanion", "lsp", "path", "snippets", "buffer" },
    },
    keymap = {
      ["<C-_>"] = { "show" }, -- Manual trigger
      ["<C-n>"] = { "select_next", "snippet_forward", "fallback" },
      ["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<Tab>"] = { "accept", "fallback" },
      ["<Esc>"] = { "hide", "fallback" },
    },
  })
end

return M
