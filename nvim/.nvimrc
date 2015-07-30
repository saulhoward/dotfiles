" neovim rc by saul@saulhoward.com

" pull in vim defaults
source ~/.vimrc

" install plugins (see vim-plug)

call plug#begin('~/.vim/plugged')

" style
Plug 'chriskempson/base16-vim'
Plug 'peaksea'
Plug 'saulhoward/kaodam'
Plug 'bling/vim-airline'

" unite
Plug 'Shougo/unite.vim'
Plug 'Shougo/unite-outline'
Plug 'Shougo/vimfiler.vim'
Plug 'Shougo/neomru.vim'

" code
Plug 'fatih/vim-go'
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'pangloss/vim-javascript'
Plug 'puppetlabs/puppet-syntax-vim'
Plug 'groenewege/vim-less'
Plug 'kchmck/vim-coffee-script'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-fugitive'

" misc
Plug 'ervandew/supertab'
Plug 'vimwiki'
Plug 'fountain.vim'
Plug 'ledger/vim-ledger'
Plug 'junegunn/goyo.vim'

" layout
Plug 'zhaocai/GoldenView.Vim'

call plug#end()

" plugin specific settings

" goldenview
let g:goldenview__enable_default_mapping=0
nmap <F4> <Plug>ToggleGoldenViewAutoResize
nmap <leader>s <Plug>GoldenViewSplit

" airline settings
" remove separators
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" remove unused modes
let g:airline_theme="dark"
let g:airline#extensions#whitespace#enabled = 0
" tabline at top
let g:airline#extensions#tabline#enabled = 1

" Unite
let g:unite_source_history_yank_enable = 1

if executable('ag')
  " Use ag in unite grep source.
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--smart-case --skip-vcs-ignores --nocolor --nogroup --hidden'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ack-grep')
  " Use ack in unite grep source.
  let g:unite_source_grep_command = 'ack-grep'
  let g:unite_source_grep_default_opts = '--no-heading --no-color --nogroup --with-filename'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ack')
  " Use ack in unite grep source.
  let g:unite_source_grep_command = 'ack'
  let g:unite_source_grep_default_opts = '--no-heading --no-color --nogroup --with-filename'
  let g:unite_source_grep_recursive_opt = ''
endif

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#custom_source('buffer,buffer_tab', 'filters',
            \ ['converters', 'converter_buffer_simple'])
au BufReadPost *.md call unite#sources#outline#alias('vimwiki', 'markdown')

nnoremap <leader>t :Unite -no-split -buffer-name=files   -start-insert file_rec/async:!<cr>
nnoremap <leader>f :Unite -no-split -buffer-name=files   -start-insert file<cr>
nnoremap <leader>r :Unite -no-split -buffer-name=mru     -start-insert file_mru<cr>
nnoremap <leader>o :Unite -no-split -buffer-name=outline -start-insert outline<cr>
nnoremap <leader>y :Unite -no-split -buffer-name=yank    history/yank<cr>
nnoremap <leader>e :Unite -no-split -buffer-name=buffer  -wrap buffer<cr>
nnoremap <leader>g :Unite -no-split -buffer-name=grep  grep:.<cr>

" Custom mappings for the unite buffer
autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  " Play nice with supertab
  let b:SuperTabDisabled=1

  " Enable navigation with control-j and control-k in insert mode
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)

  nmap <buffer> <ESC> <Plug>(unite_exit)
endfunction

"vimfiler
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_enable_auto_cd  = 1
" Enable file operation commands.
"let g:vimfiler_safe_mode_by_default = 0
let g:vimfiler_tree_leaf_icon = ' '
let g:vimfiler_tree_opened_icon = '▾'
let g:vimfiler_tree_closed_icon = '▸'
let g:vimfiler_file_icon = '-'
let g:vimfiler_marked_file_icon = '*'

" nnoremap <silent> <leader>d :<C-u>VimFilerExplorer<CR>
nnoremap <silent> <leader>d :<C-u>VimFiler -quit -buffer-name=explorer<CR>

" Copy file to clipboard
nmap <F3> :silent %w !xclip -selection clipboard<CR>

" vimwiki
let g:vimwiki_list = [{'path': '~/sync/wiki/',
                     \ 'syntax': 'markdown', 'ext': '.md'}]

" Colors **********************************************************************
" Has to be after bundle because theme is loaded then
syntax on
set background=dark
if has("gui_running")
    colorscheme base16-monokai
    set guifont=Ubuntu\ Mono\ 14
    set guioptions-=m  "menu bar
    set guioptions-=T  "toolbar
    set guioptions+=LlRrb "scrollbars
    set guioptions-=LlRrb
    set lines=73 columns=260
" elseif &diff
"     set t_Co=256
"     set background=dark
"     colorscheme peaksea
else
    set t_Co=256
    colorscheme base16-monokai
endif

" Colorscheme overrides
hi Comment cterm=italic gui=italic

" Set zazen colorscheme for fountain
" autocmd! BufEnter,BufNewFile *.fountain colo zazen
" autocmd! BufLeave *.fountain colo base16-monokai

" disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
if &term =~ 'rxvt'
  set t_ut=
endif

" SuperTab
"let g:SuperTabDefaultCompletionType = "<c-n>"
