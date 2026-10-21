" Shared settings for vim and nvim. Plain vim (e.g. over ssh) uses this
" as-is; nvim sources it from init.lua, then adds the theme and plugins.

" Vim: match nvim's defaults ****************************************************
if !has('nvim')
  set nocompatible
  syntax on
  filetype plugin indent on
  set autoindent autoread backspace=indent,eol,start display=lastline
  set encoding=utf-8 hidden history=10000 incsearch laststatus=2
  set nrformats-=octal ruler showcmd smarttab ttimeout ttimeoutlen=50 wildmenu
  set belloff=all
  " vim and nvim undo files are incompatible, so keep vim's separate
  set undodir=~/.vim/undo//
  if !isdirectory(expand('~/.vim/undo')) | call mkdir(expand('~/.vim/undo'), 'p') | endif
  try | colorscheme habamax | catch | colorscheme desert | endtry
endif

" Options ***********************************************************************
set number
set mouse=a
set cursorline
let &colorcolumn = '80,' . join(range(120, 999), ',')
set title
set shortmess+=I

set nowrap linebreak
set scrolloff=10 sidescrolloff=5
set whichwrap=h,l,~,[,]
set listchars=tab:»·,trail:·,nbsp:␣

set splitbelow splitright
set noequalalways

set ignorecase smartcase
set nohlsearch

set expandtab tabstop=2 softtabstop=2 shiftwidth=2 shiftround

set noswapfile nobackup nowritebackup
set undofile

" bash-style command-line completion
set wildmode=longest,list
set wildignore+=*.o,*.obj,*.pyc,*.class,*.DS_Store

" Keys **************************************************************************
let mapleader = ' '

" move between windows; , cycles
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap , <C-w>w

" cycle buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" blank line below/above without entering insert mode
nnoremap - :put=''<CR>
nnoremap + :put!=''<CR>

" reformat paragraph / selection
nnoremap Q gwap
xnoremap Q gw

nnoremap Y y$

" toggles
nnoremap <leader>tl :set list! list?<CR>
nnoremap <leader>tn :set number! number?<CR>
nnoremap <leader>tw :set wrap! wrap?<CR>
nnoremap <leader>th :set hlsearch! hlsearch?<CR>

nnoremap <leader>r :edit!<CR>
nnoremap <leader>v :edit $MYVIMRC<CR>

" save as root (vim only: nvim can't prompt for sudo's password)
if !has('nvim')
  cnoremap w!! w !sudo tee > /dev/null %
endif

" forgive :W and :Q
command! -bang -nargs=* -complete=file W write<bang> <args>
command! -bang Q quit<bang>

" Autocommands ******************************************************************
augroup vimrc
  autocmd!
  " jump to the last cursor position, except in commit messages
  autocmd BufReadPost * if &filetype !~# 'commit' && line("'\"") >= 1 && line("'\"") <= line('$')
        \ | execute 'normal! g`"' | endif
  " pick up changes made outside the editor
  autocmd FocusGained,BufEnter,CursorHold * silent! checktime
  " prose
  autocmd BufRead,BufNewFile *.fountain setfiletype fountain
  autocmd FileType markdown,text,fountain setlocal wrap textwidth=80
  " help: Enter follows a link, Backspace goes back
  autocmd FileType help nnoremap <buffer> <CR> <C-]>
  autocmd FileType help nnoremap <buffer> <BS> <C-t>
augroup END
