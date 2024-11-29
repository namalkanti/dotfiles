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
Plug 'guns/vim-clojure-static'
Plug 'luochen1990/rainbow'
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

nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-c> <c-w>c
nnoremap <c-o> <c-w>o

"Ctags location
set tags^=.git/tags;/

"Fzf and Rg
nmap <C-p> :Files<CR>
nmap <C-b> :Buffers<CR>
command! FzfRg call fzf#vim#grep('rg --line-number --no-heading --color=always .', 1)
nmap <C-i> :FzfRg<CR>

set guifont=Monaco:h16
