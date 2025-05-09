-- lua/config/blink.lua

local M = {}

-- Global toggle variable
_G.blink_cmp_enabled = false

local function apply_cmp_setup()
  local ok, cmp = pcall(require, "blink.cmp")
  if not ok then
    vim.notify("blink.cmp not found!", vim.log.levels.ERROR)
    return
  end

  cmp.setup({
    sources = {
      default = { "codecompanion", "lsp", "path", "snippets", "buffer" },
    },
    keymap = {
      ["<C-_>"] = { "show" }, -- Manual completion menu trigger
      ["<C-n>"] = { "select_next", "snippet_forward", "fallback" },
      ["<C-p>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<Tab>"] = { "accept", "fallback" },
      ["<Esc>"] = { "hide", "fallback" },
    },
    enabled = function()
      return _G.blink_cmp_enabled
    end,
    -- No auto_show here; it's not supported!
  })
end

function M.toggle_cmp()
  _G.blink_cmp_enabled = not _G.blink_cmp_enabled
  apply_cmp_setup()
  vim.notify("Blink cmp enabled: " .. (_G.blink_cmp_enabled and "ON" or "OFF"))
end

function M.setup()
  apply_cmp_setup()
  vim.api.nvim_set_keymap(
    'n',
    '<leader>ta',
    '<cmd>lua require("config.blink").toggle_cmp()<CR>',
    { noremap = true, silent = true }
  )
end

return M

