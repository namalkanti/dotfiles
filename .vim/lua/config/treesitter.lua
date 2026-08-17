--
-- lua/config/treesitter.lua
-- Treesitter parser install + highlighting/indent/folding.
--
local treesitter_module = {}

local parsers = {
  'cpp', 'c', 'python', 'rust', 'clojure', 'kotlin',
  'typescript', 'tsx', 'go', 'haskell', 'ocaml', 'ocaml_interface', 'lua',
}

local filetypes = {
  'cpp', 'c', 'python', 'rust', 'clojure', 'kotlin',
  'typescript', 'typescriptreact', 'go', 'haskell', 'ocaml', 'lua',
}

function treesitter_module.setup()
  require('nvim-treesitter').install(parsers)

  -- Folds start open; close what you want with zc/zM instead of pre-closed.
  vim.o.foldlevelstart = 99

  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function()
      vim.treesitter.start()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
  })
end

return treesitter_module
