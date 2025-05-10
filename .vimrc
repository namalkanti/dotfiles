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
" Code companion dependencies
Plug 'github/copilot.vim'
Plug 'saghen/blink.cmp', { 'tag': 'v0.*' }
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
autocmd FileType markdown setlocal wrap linebreak showbreak=↪\
autocmd FileType markdown nnoremap <buffer> j gj
autocmd FileType markdown nnoremap <buffer> k gk

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

" Horizontal scrolling
nnoremap <silent> <Left> zh
nnoremap <silent> <Right> zl

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
lua require('config.codecompanion').setup()
lua require('config.blink').setup()
lua require('config.lsp').setup()


" 4) (Optional) Enable built-in LSP-based completion
let g:copilot_enabled = 0
set completeopt=menuone,noinsert,noselect
set omnifunc=v:lua.vim.lsp.omnifunc
let g:copilot_enabled = 0
