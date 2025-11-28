-- lua/myconfig/codecompanion.lua
-- Configures Code Companion in its own Lua module so the setup block
-- disappears from init.vim.  Key‑mappings stay identical to your old
-- Vim‑script.

local code_companion_module = {}

local cc = require("codecompanion")

function code_companion_module.setup()
  -- Core configuration: Copilot adapter for all strategies
  cc.setup({
    strategies = {
      chat   = { adapter = "copilot" },
      inline = { adapter = "copilot" },
      cmd    = { adapter = "copilot" },
    },
      -- Setting default diff to vertical split
    display = {
        diff = {
            enabled = true,
            provider = "split",
            layout = "vertical",
        },
    },
  })

  -- Key‑maps (identical behaviour to your previous config)
  local opts = { noremap = true, silent = true }
  vim.keymap.set({ "n", "v" }, "<Leader>ca", "<cmd>CodeCompanionActions<cr>", opts)
  vim.keymap.set({ "n", "v" }, "<Leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", opts)
  vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", opts)

  -- Command‑line abbreviation:  :cc  ⇒  :CodeCompanion
  vim.cmd([[cabbrev <expr> cc getcmdtype() == ':' ? 'CodeCompanion' : 'cc']])
end

return code_companion_module
