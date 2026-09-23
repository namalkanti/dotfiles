--
-- lua/config/textobjects.lua
-- Treesitter-based text objects and structural movement.
--
local textobjects_module = {}

function textobjects_module.setup()
  require('nvim-treesitter-textobjects').setup {
    select = {
      lookahead = true,
      include_surrounding_whitespace = false,
    },
    move = {
      set_jumps = true,
    },
  }

  local select = require('nvim-treesitter-textobjects.select')
  local move = require('nvim-treesitter-textobjects.move')
  local swap = require('nvim-treesitter-textobjects.swap')

  local function select_map(keys, capture)
    vim.keymap.set({ 'x', 'o' }, keys, function()
      select.select_textobject(capture, 'textobjects')
    end)
  end

  select_map('af', '@function.outer')
  select_map('if', '@function.inner')
  select_map('ac', '@class.outer')
  select_map('ic', '@class.inner')
  select_map('aa', '@parameter.outer')
  select_map('ia', '@parameter.inner')

  vim.keymap.set('n', '<leader>a', function()
    swap.swap_next('@parameter.inner')
  end, { desc = 'Swap next parameter' })
  vim.keymap.set('n', '<leader>A', function()
    swap.swap_previous('@parameter.inner')
  end, { desc = 'Swap previous parameter' })

  vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
    move.goto_next_start('@function.outer', 'textobjects')
  end, { desc = 'Next function start' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
    move.goto_previous_start('@function.outer', 'textobjects')
  end, { desc = 'Previous function start' })
end

return textobjects_module
