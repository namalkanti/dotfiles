call plug#begin('~/.vim/bundle/')
Plug 'rose-pine/vim' 
Plug 'itchyny/lightline.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'godlygeek/tabular'
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

set tags^=.git/tags;/

if executable('ag')
  let g:ackprg = 'ag --vimgrep --nogroup --nocolor --column'
endif
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
