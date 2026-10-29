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

nnoremap Y y$

" == on a comment reflows just that comment to 80 columns; on code it
" reindents as usual (prose files override this below)
function! s:LineComment() abort
  " the run of lines starting with the line-comment leader, e.g. # or //
  let leader = matchstr(&commentstring, '^\s*\zs\S\+\ze\s*%s')
  let pat = '^\s*\V' . escape(leader, '\') . '\m\%(\s\|$\)'
  if empty(leader) || getline('.') !~# pat | return [] | endif
  let [first, last] = [line('.'), line('.')]
  while first > 1 && getline(first - 1) =~# pat | let first -= 1 | endwhile
  while last < line('$') && getline(last + 1) =~# pat | let last += 1 | endwhile
  return [first, last]
endfunction
function! s:BlockComment() abort
  " the lines of the /* ... */-style comment around the cursor, using the
  " start/end markers from 'comments' (O-flagged ones are list bullets)
  let [cur, view, start] = [line('.'), winsaveview(), '']
  for part in split(&comments, ',')
    let [flags, str] = matchlist(part, '^\([^:]*\):\(.*\)$')[1:2]
    if flags =~# 's' && flags !~# 'O'
      let start = str
    elseif flags =~# 'e' && !empty(start)
      call cursor(cur, col('$'))
      let [sl, sc] = searchpos('\V' . escape(start, '\'), 'bcnW')
      if sl
        call cursor(sl, sc + len(start))
        let el = searchpos('\V' . escape(str, '\'), 'cnW')[0]
        call winrestview(view)
        if el >= cur | return [sl, el] | endif
      endif
      call winrestview(view)
      let start = ''
    endif
  endfor
  return []
endfunction
function! s:Reflow() abort
  let range = s:LineComment()
  if empty(range) | let range = s:BlockComment() | endif
  if empty(range)
    execute 'normal! ' . v:count1 . '=='
    return
  endif
  let tw = &l:textwidth
  if !tw | setlocal textwidth=80 | endif
  execute 'normal! ' . range[0] . 'Ggw' . range[1] . 'G'
  let &l:textwidth = tw
endfunction
nnoremap <silent> == <Cmd>call <SID>Reflow()<CR>

" prose settings live in ~/.vim/prose.vimrc so Obsidian can share them; apply
" them to the current buffer only
function! s:Prose() abort
  let file = expand('~/.vim/prose.vimrc')
  if !filereadable(file) | return | endif
  for line in readfile(file)
    if line =~# '^\s*\%("\|$\)' | continue | endif
    execute substitute(line, '^\s*\a*map\zs\s', ' <buffer> ', '')
  endfor
endfunction

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
  autocmd FileType markdown,text,fountain setlocal wrap | call s:Prose()
  " help: Enter follows a link, Backspace goes back
  autocmd FileType help nnoremap <buffer> <CR> <C-]>
  autocmd FileType help nnoremap <buffer> <BS> <C-t>
augroup END
