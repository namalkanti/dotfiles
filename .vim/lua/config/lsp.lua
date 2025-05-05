-- lua/config/lsp.lua
-- LSP server setup.  Uses _BLINKCAPS exported by blinkcmp.lua so that
-- completion works with the language servers.

local lsp_module = {}

local lspconfig = require("lspconfig")

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
  lspconfig.pyright.setup({
    on_attach   = make_on_attach(),
    capabilities = capabilities,
  })

  -- Rust
  lspconfig.rust_analyzer.setup({
    on_attach   = make_on_attach(),
    capabilities = capabilities,
  })

  -- Markdown (Marksman)
  lspconfig.marksman.setup({
    on_attach   = make_on_attach(),
    capabilities = capabilities,
  })

  -- C/C++/Objective‑C (clangd)
  lspconfig.clangd.setup({
    on_attach   = make_on_attach(),
    capabilities = capabilities,
    -- Extra clangd flags can go here
  })
end

return lsp_module
