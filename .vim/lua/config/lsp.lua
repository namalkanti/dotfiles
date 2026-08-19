------
-- lua/config/lsp.lua
-- LSP server setup.  
--
local lsp_module = {}


-- Read capabilities from blinkcmp (fallback to default table if nil)
local capabilities = _G._BLINKCAPS or vim.lsp.protocol.make_client_capabilities()

function lsp_module.setup()
  vim.lsp.config('pyright', { capabilities = capabilities })
  vim.lsp.config('rust_analyzer', {
    capabilities = capabilities,
    settings = { ['rust-analyzer'] = { check = { command = 'clippy' } } },
  })
  vim.lsp.config('marksman', { capabilities = capabilities })
  vim.lsp.config('clangd', { capabilities = capabilities })
  vim.lsp.config('ts_ls', { capabilities = capabilities })

  vim.lsp.enable({ 'pyright', 'rust_analyzer', 'marksman', 'clangd', 'ts_ls' })
end

return lsp_module
