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

      local language = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
      local has_indent_query, indent_query = pcall(vim.treesitter.query.get, language, 'indents')
      if has_indent_query and indent_query then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
  })
end

return treesitter_module
