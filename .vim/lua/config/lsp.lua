------
-- lua/config/lsp.lua
-- LSP server setup.  Uses _BLINKCAPS exported by blinkcmp.lua so that
-- completion works with the language servers.

local lsp_module = {}

-- Wrapper to bridge to your Vimscript LspOnAttach() for buffer keymaps
local function make_on_attach()
  return function(client, bufnr)
    vim.cmd("call LspOnAttach(" .. client.id .. "," .. bufnr .. ")")
  end
end

-- Read capabilities from blinkcmp (fallback to default table if nil)
local capabilities = _G._BLINKCAPS or vim.lsp.protocol.make_client_capabilities()

function lsp_module.setup()
  -- Python
  vim.lsp.config('pyright', {
    on_attach    = make_on_attach(),
    capabilities = capabilities,
  })

  -- Rust
  vim.lsp.config('rust_analyzer', {
    on_attach    = make_on_attach(),
    capabilities = capabilities,
  })

  -- Markdown (Marksman)
  vim.lsp.config('marksman', {
    on_attach    = make_on_attach(),
    capabilities = capabilities,
  })

  -- C/C++/Objective-C (clangd)
  vim.lsp.config('clangd', {
    on_attach    = make_on_attach(),
    capabilities = capabilities,
    -- Extra clangd flags can go here
    -- cmd = { "clangd", "--background-index" },
  })
end

return lsp_module
