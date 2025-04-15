call plug#begin('~/.vim/bundle/')
Plug 'rose-pine/vim', {'as': 'rosepine'} 
Plug 'itchyny/lightline.vim'
Plug '/bin/fzf'
Plug 'junegunn/fzf.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'godlygeek/tabular'
Plug 'rust-lang/rust.vim'
Plug 'udalov/kotlin-vim'
Plug 'neovim/nvim-lspconfig'

"AI Coding
Plug 'github/copilot.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'olimorris/codecompanion.nvim'
call plug#end()

set nocompatible
set encoding=utf-8
set showcmd

set background=dark
colorscheme rosepine
let g:lightline = {
      \ 'colorscheme': 'rosepine',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'relativepath' ],
      \              [ 'lineinfo' ],
      \              [ 'percent' ]],
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

set nowrap
set tabstop=4 shiftwidth=4
set expandtab
set backspace=indent,eol,start

set hlsearch
set incsearch
set ignorecase
set smartcase

set number

set ttimeout
set ttimeoutlen=1

"Leader remap
let mapleader = " "

"Remap jumplist
nnoremap gf <C-i>
nnoremap gb <C-o>

"Window Navigation
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-c> <c-w>c
nnoremap <c-o> <c-w>o

"Fzf and Rg
nmap <C-p> :Files<CR>
nmap <C-b> :Buffers<CR>
command! FzfRg call fzf#vim#grep('rg --line-number --no-heading --color=always .', 1)
nmap <C-i> :FzfRg<CR>

set guifont=Monaco:h16

"LSP Setup
" 2) Define a Vimscript function to set up LSP keymaps when server attaches
function! LspOnAttach(client, bufnr) abort
  nnoremap <silent> <buffer> gd :lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> <buffer> gr :lua vim.lsp.buf.references()<CR>
  nnoremap <silent> <buffer> K  :lua vim.lsp.buf.hover()<CR>
  nnoremap <silent> <buffer> <leader>e :lua vim.diagnostic.open_float()<CR>
  nnoremap <silent> <buffer> <leader>rn :lua vim.lsp.buf.rename()<CR>
  nnoremap <silent> <buffer> <leader>ca :lua vim.lsp.buf.code_action()<CR>
  nnoremap <silent> <buffer> <leader>f :lua vim.lsp.buf.format({ async=true })<CR>
endfunction

" 3) Configure your language servers and code companion in a Lua block
lua << EOF
  local lspconfig = require("lspconfig")

  -- Helper callback: call our Vimscript LspOnAttach
  local function make_on_attach()
    return function(client, bufnr)
      vim.cmd("call LspOnAttach(" .. client.id .. "," .. bufnr .. ")")
    end
  end

  -- Pyright (Python)
  lspconfig.pyright.setup({
    on_attach = make_on_attach()
  })

  -- rust-analyzer (Rust)
  lspconfig.rust_analyzer.setup({
    on_attach = make_on_attach()
  })

  -- marksman (Markdown)
  lspconfig.marksman.setup({
    on_attach = make_on_attach()
  })

  -- clangd (C/C++/Objective-C)
  lspconfig.clangd.setup({
    on_attach = make_on_attach(),
    -- Additional clangd settings can go here
    -- e.g. cmd = {"clangd", "--background-index", ...},
  })

  -- Code Companion Setup
  require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "copilot",
        }
      },
  })
  vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
  vim.keymap.set({ "n", "v" }, "<Leader>tc", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
  vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])
EOF

" 4) (Optional) Enable built-in LSP-based completion
set completeopt=menuone,noinsert,noselect
set omnifunc=v:lua.vim.lsp.omnifunc
