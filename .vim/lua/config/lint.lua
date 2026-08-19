------
-- lua/config/lint.lua
-- Standalone linters (nvim-lint), separate from LSP diagnostics.
--
local lint_module = {}

local eslint_configs = { 'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', 'eslint.config.ts' }

local function has_eslint_config()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then return false end
  return #vim.fs.find(eslint_configs, { upward = true, path = vim.fs.dirname(bufname) }) > 0
end

function lint_module.setup()
  local lint = require('lint')

  lint.linters_by_ft = {
    c = { 'clangtidy' },
    cpp = { 'clangtidy' },
    python = { 'ruff' },
    clojure = { 'clj-kondo' },
  }

  local js_filetypes = { typescript = true, typescriptreact = true, javascript = true, javascriptreact = true }

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('lint', { clear = true }),
    callback = function()
      local ft = vim.bo.filetype
      local linters = lint.linters_by_ft[ft] or {}

      if js_filetypes[ft] and has_eslint_config() then
        linters = vim.list_extend(vim.deepcopy(linters), { 'eslint' })
      end

      if #linters > 0 then
        lint.try_lint(linters)
      end
    end,
  })
end

return lint_module
