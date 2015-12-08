" neovim rc by saul@saulhoward.com

" pull in vim defaults
source ~/.vimrc

" install plugins (see vim-plug)

call plug#begin('~/.vim/plugged')

" style
Plug 'bling/vim-airline'
Plug 'airblade/vim-gitgutter'
" Plug 'chriskempson/base16-vim'
" Plug 'peaksea'
Plug 'geoffharcourt/one-dark.vim'
Plug 'reedes/vim-colors-pencil'

" unite
Plug 'Shougo/unite.vim'
Plug 'Shougo/unite-outline'
Plug 'Shougo/vimfiler.vim'
Plug 'Shougo/neomru.vim'
Plug 'soh335/unite-outline-go'
Plug 'osyo-manga/unite-quickfix'

" code
Plug 'tomtom/tcomment_vim'
Plug 'fatih/vim-go'
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'kchmck/vim-coffee-script'
Plug 'puppetlabs/puppet-syntax-vim'
Plug 'groenewege/vim-less'
Plug 'tpope/vim-fugitive'
" needs `npm install -g jsfmt`
Plug 'mephux/vim-jsfmt'
Plug 'editorconfig/editorconfig-vim'
Plug 'cohama/lexima.vim'
Plug 'tpope/vim-surround'

" misc
Plug 'ervandew/supertab'
Plug 'airblade/vim-rooter'
Plug 'vimwiki'
Plug 'fountain.vim'
Plug 'ledger/vim-ledger'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'reedes/vim-pencil'

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
let g:airline_theme="badwolf"
let g:airline#extensions#whitespace#enabled = 0
" tabline at top
let g:airline#extensions#tabline#enabled = 1

" Unite
let g:unite_source_history_yank_enable = 1

if executable('ag')
  " Use ag in unite grep source.
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--smart-case --nocolor --nogroup --hidden'
  let g:unite_source_grep_recursive_opt = ''
  " use ag for file_rec
  let g:unite_source_rec_async_command= 'ag --nocolor --nogroup --ignore ''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'' --hidden -g ""'
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

call unite#custom_source('file_rec', 'matchers', ['matcher_fuzzy'])
call unite#custom_source('buffer,buffer_tab', 'converters', 'converter_buffer_simple')
call unite#sources#outline#alias('javascript.jsx', 'javascript')
au BufReadPost *.md call unite#sources#outline#alias('vimwiki', 'markdown')

nnoremap <leader>f :Unite -no-split -buffer-name=files   -start-insert file<cr>
nnoremap <leader>r :Unite -no-split -buffer-name=mru     -start-insert file_mru<cr>
nnoremap <leader>o :Unite -no-split -buffer-name=outline -start-insert outline<cr>
nnoremap <leader>y :Unite -no-split -buffer-name=yank    history/yank<cr>
nnoremap <leader>e :Unite -no-split -buffer-name=buffer  -wrap buffer<cr>
nnoremap <leader>g :Unite -no-split -buffer-name=grep  grep:.<cr>
nnoremap <leader>q :Unite -no-split -buffer-name=quickfix quickfix<cr>
nnoremap <leader>t :Unite -no-split -buffer-name=files -start-insert file_rec/async:!<cr>

" Custom mappings for the unite buffer
autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  " Allow supertab
  imap <buffer> <Tab>   <Plug>SuperTabForward

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
    colorscheme onedark
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
    " let base16colorspace=256
    " colorscheme base16-monokai
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1 "requires true color terminal
    colorscheme onedark
endif

" Colorscheme overrides
hi Comment cterm=italic gui=italic

" Set zazen colorscheme for fountain
" autocmd! BufEnter,BufNewFile *.fountain colo zazen
" autocmd! BufLeave *.fountain colo base16-monokai

" disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
" if &term =~ 'rxvt'
"   set t_ut=
" endif

" SuperTab
"let g:SuperTabDefaultCompletionType = "<c-n>"
let g:SuperTabDefaultCompletionType = "context"

" Goyo
let g:limelight_conceal_guifg = 1 " nvim truecolor fix
function! s:goyo_enter()
    set background=dark
    let g:pencil_terminal_italics = 1
    colorscheme pencil
    Limelight
endfunction
function! s:goyo_leave()
    colorscheme onedark
    Limelight!
endfunction
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
nnoremap <leader>z :Goyo<cr>

" JSX (for .js files as well)
let g:jsx_ext_required = 0

" jsfmt
" let g:js_fmt_command = "esformatter"
" let g:js_fmt_autosave = 1

" use goimports for rewriting import lines
let g:go_fmt_command = "goimports"

" Pencil
let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,md,vimwiki call pencil#init()
  autocmd FileType text                    call pencil#init({'wrap': 'hard'})
augroup END

set noautochdir

" nvim terminal mode
:tnoremap <Esc> <C-\><C-n>

" editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
