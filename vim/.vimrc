"vimrc by Saul <saul@saulhoward.com>

set nocompatible

autocmd!
set autoread
set wildmenu
set viminfo=/50,'50,h
set hidden
set backspace=indent,eol,start
set number
set showmatch
set matchpairs+=<:>
set comments=s1:/*,mb:*,ex:*/,f://,b:#,:%,:XCOMM,n:>,fb:-
set encoding=utf-8
set nobackup
set nowb
set noswapfile
set history=100
set autowrite
set report=0
set runtimepath+=~/.vim
set previewheight=8
set ls=2
execute 'set listchars+=tab:' . nr2char(187) . nr2char(183)
au CursorHold * checktime
set shiftround
set sidescrolloff=2
set scrolloff=2
set title
set ruler
set showmode
set showcmd
set mouse=a

" use spaces
set shiftwidth=4
set tabstop=4
set smarttab
set expandtab

" use tabs
" set autoindent
" set noexpandtab
" set tabstop=4
" set shiftwidth=4

" Bash tab style completion is awesome
set wildmode=longest,list
" wildchar-the char used for "expansion" on the command line default value is
" "<C-E>" but I prefer the tab key:
set wildchar=<TAB>
" ignore these files when completing
set wildignore=*~,#*#,*.sw?,*.o,*.obj,*.bak,*.exe,*.pyc,*.DS_Store,*.db,*.class,*.java.html,*.cgi.html,*.html.html,.viminfo,*.pdf

set shortmess=flnrxoOItTA

" Windows *********************************************************************
set splitbelow splitright
set noequalalways

" Cursor highlights ***********************************************************
set cursorline

" Searching *******************************************************************
set hlsearch
set ignorecase
set smartcase
set incsearch
set gdefault
set mousehide

" Omni Completion *************************************************************
" set ofu=syntaxcomplete#Complete
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

" Line Wrapping ***************************************************************
set nowrap
set linebreak
" have the h and l cursor keys wrap between lines (like <Space> and <BkSpc> do
" by default), and ~ covert case over line breaks; also have the cursor keys
" wrap in insert mode:
set whichwrap=h,l,~,[,]
set formatoptions=cq
set textwidth=72
set comments+=b:\"
set comments+=n::

" Colour column
" let &colorcolumn=join(range(81,999),",")
let &colorcolumn="80,".join(range(120,999),",")

" File Stuff ******************************************************************
" To show current filetype use: set filetype
filetype plugin indent on

" Filetypes (au = autocmd)
au FileType helpfile set nonumber      " no line numbers when viewing help
au FileType helpfile nnoremap <buffer><cr> <c-]>   " Enter selects subject
au FileType helpfile nnoremap <buffer><bs> <c-T>   " Backspace to go back

au BufNewFile,BufRead *.html        setf xhtml
au BufNewFile,BufRead *.lzx         setf lzx
au BufNewFile,BufRead *.module      setf php
au BufNewFile,BufRead *.inc         setf php
au BufNewFile,BufRead *.pl,*.pm,*.t setf perl
au BufRead,BufNewFile *.twig set filetype=htmldjango
au FileType c,cpp,slang        set cindent
au FileType c set formatoptions+=ro
au FileType perl set smartindent
au FileType python set formatoptions-=t
au FileType css set smartindent
au FileType xhtml set formatoptions+=l
au FileType xhtml set formatoptions-=t
au FileType htmldjango set formatoptions+=l
au FileType htmldjango set formatoptions-=t

au BufNewFile,BufRead *.txt         setf txt
au FileType txt set formatoptions+=t
au FileType mail set formatoptions+=t

" markdown
au BufRead,BufNewFile *.md set filetype=markdown
augroup mkd
    autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END
au BufRead,BufNewFile *.fountain     set filetype=fountain
" no text wrapping for markdown, fountain
au BufRead,BufNewFile *.fountain,*.mkd set wrap linebreak nolist textwidth=0 wrapmargin=0

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.svn,.git,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
au BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
  if &filetype !~ 'commit\c'
    if line("'\"") > 0 && line("'\"") <= line("$")
     exe "normal g`\""
    endif
  end
endfunction

" tell complete to look in the dictionary
set complete-=k complete+=k

au FileType * exec('setlocal dict+='.$VIMRUNTIME.'/syntax/'.expand('<amatch>').'.vim')

au BufRead,BufNewFile *.pp              set filetype=puppet

" autocmd FileType go autocmd BufWritePre <buffer> Fmt

" Redraw *********************************************************************
set ttyfast
"set ttyscroll=0

" -----------------------------------------------------------------------------
" | Aliases and custom key functions                                          |
" -----------------------------------------------------------------------------
noremap <Space> <PageDown>
nnoremap <F1> :help<Space>
vmap <F1> <C-C><F1>
omap <F1> <C-C><F1>
map! <F1> <C-C><F1>
map <Esc>[Z <s-tab>
ounmap <Esc>[Z
" use <Ctrl>+N/<Ctrl>+P to cycle through files:
" [<Ctrl>+N by default is like j, and <Ctrl>+P like k.]
nnoremap <C-N> :bn<CR>
nnoremap <C-P> :bp<CR>
" swap windows
nmap , <C-w><C-w>
"move around windows with ctrl key!
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
" insert new line without going into insert mode
nnoremap - :put=''<CR>
nnoremap + :put!=''<CR>
" have Q reformat the current paragraph (or selected text if there is any):
nnoremap Q gqap
vnoremap Q gq
" have Y behave analogously to D and C rather than to dd and cc (which is
" already done by yy):
noremap Y y$
" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>
" toggle paste on/off
nnoremap \tp :set invpaste paste?<CR>
"toggle list on/off and report the change:
nnoremap \tl :set invlist list?<CR>
"toggle highlighting of search matches, and report the change:
nnoremap \th :set invhls hls?<CR>
"toggle numbers
nnoremap \tn :set number!<Bar> set number?<CR>
"clear the search buffer, not just remove the highlight
map \h :let @/ = ""<CR>

" Revert the current buffer
nnoremap \r :e!<CR>

"Easy edit of vimrc
"nmap \s :source $MYVIMRC<CR>
nmap \v :e $MYVIMRC<CR>

"show indent settings
nmap \I :verbose set ai? cin? cink? cino? si? inde? indk? formatoptions?<CR>

"replace all tabs with 4 spaces
map \ft :%s/	/    /g<CR>

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" reload file as sudo user
cmap w!! %!sudo tee > /dev/null %

" make space execute the 'q' macro (press qq to start recording, q to
" stop,then [space] to execute.  super convenient)                            
noremap <Space> @q

" color
colorscheme desert
