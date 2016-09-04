" neovim rc by saul@saulhoward.com

" pull in vim defaults
source ~/.vimrc

" install plugins (see vim-plug)

call plug#begin('~/.vim/plugged')

" style
Plug 'bling/vim-airline'
Plug 'geoffharcourt/one-dark.vim'
Plug 'whatyouhide/vim-gotham'
Plug 'reedes/vim-colors-pencil'
" Plug 'junegunn/vim-emoji'

" unite
Plug 'Shougo/unite.vim'
Plug 'Shougo/unite-outline'
Plug 'Shougo/vimfiler.vim'
Plug 'Shougo/neoyank.vim'
Plug 'Shougo/neomru.vim'
Plug 'soh335/unite-outline-go'
Plug 'osyo-manga/unite-quickfix'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" editing
Plug 'vim-scripts/matchit.zip'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'

" wiki/notes
Plug 'godlygeek/tabular'
Plug 'vimwiki'
Plug 'fmoralesc/vim-pad'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" code
Plug 'tomtom/tcomment_vim'
Plug 'fatih/vim-go', {'for' : 'go'}
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'pangloss/vim-javascript', {'for' : 'javascript'}
Plug 'mxw/vim-jsx', {'for' : 'javascript'}
Plug 'kchmck/vim-coffee-script', {'for' : 'coffee'}
Plug 'puppetlabs/puppet-syntax-vim', {'for' : 'puppet'}
Plug 'groenewege/vim-less', {'for' : 'less'}
" Plug 'mephux/vim-jsfmt', {'for' : 'javascript'} " needs `npm install -g jsfmt`
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-ruby/vim-ruby', {'for' : 'ruby'}
Plug 'elzr/vim-json', {'for' : 'json'}
Plug 'ekalinin/Dockerfile.vim', {'for' : 'Dockerfile'}
Plug 'fatih/vim-nginx' , {'for' : 'nginx'}
Plug 'corylanou/vim-present', {'for' : 'present'}
Plug 'keith/swift.vim', {'for' : 'swift'}
Plug 'plasticboy/vim-markdown'
Plug 'cespare/vim-toml', {'for': 'toml'}
Plug 'rust-lang/rust.vim', {'for': 'rust'}
Plug 'phildawes/racer', {'for': 'rust'}
Plug 'racer-rust/vim-racer', {'for': 'rust'}
Plug 'othree/html5.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'ap/vim-css-color'

" deoplete
" let g:python3_host_prog  = '/usr/local/bin/python3.5' " for neovim python-client
" let g:python3_host_skip_check = 1
function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'zchee/deoplete-go', { 'for': 'go', 'do': 'make'}
Plug 'carlitux/deoplete-ternjs', { 'for': 'javascript' }

" snippets
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'

" misc
Plug 'airblade/vim-rooter'
Plug 'fountain.vim'
Plug 'ledger/vim-ledger'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'reedes/vim-pencil'

" layout
Plug 'cHoco/GoldenView.Vim'
Plug 'blueyed/vim-diminactive'

call plug#end()

" plugin specific settings

" goldenview
let g:goldenview__enable_at_startup=0
let g:goldenview__enable_default_mapping=0
nmap <F4> <Plug>ToggleGoldenViewAutoResize
nmap <leader>s <Plug>GoldenViewSplit

" airline settings
" remove separators
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_theme="onedark"
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
let g:vimwiki_global_ext = 0
let g:vimwiki_folding = 1
let g:vimwiki_list = [{'path': '~/sync/wiki/',
                     \ 'syntax': 'markdown', 'ext': '.md'}]

"move around windows with ctrl key!
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l

" markdown
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_folding_level = 3

" Colors **********************************************************************
" Has to be after bundle because theme is loaded then
syntax on
set background=dark
if has("gui_running")
    colorscheme onedark
    let g:onedark_nonitalic = 0
    set guifont=Ubuntu\ Mono\ 14
    set guioptions-=m  "menu bar
    set guioptions-=T  "toolbar
    set guioptions+=LlRrb "scrollbars
    set guioptions-=LlRrb
    set lines=73 columns=260
" elseif &diff
"     colorscheme peaksea
else
    " let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    set termguicolors " true colors
    colorscheme onedark
endif

" Colorscheme overrides
hi Comment cterm=italic gui=italic
" hi ColorColumn ctermbg=0 guibg=#000000 " used by diminactive

" Set zazen colorscheme for fountain
" autocmd! BufEnter,BufNewFile *.fountain colo zazen
" autocmd! BufLeave *.fountain colo base16-monokai

" disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
" if &term =~ 'rxvt'
"   set t_ut=
" endif

" Goyo
function! s:goyo_enter()
    " DisableGoldenViewAutoResize
    set scrolloff=999
    set background=dark
    " let g:pencil_terminal_italics = 1
    " colorscheme pencil
    colorscheme gotham
    let g:limelight_conceal_ctermfg = 0
    Limelight
endfunction
function! s:goyo_leave()
    EnableGoldenViewAutoResize
    colorscheme onedark
    set scrolloff=2
    Limelight!
endfunction
autocmd! User GoyoEnter
autocmd! User GoyoLeave
autocmd  User GoyoEnter nested call <SID>goyo_enter()
autocmd  User GoyoLeave nested call <SID>goyo_leave()
nnoremap <leader>z :Goyo<cr>

" JSX (for .js files as well)
let g:jsx_ext_required = 0

" jsfmt
" let g:js_fmt_command = "esformatter"
" let g:js_fmt_autosave = 1

" Go
" use goimports for rewriting import lines
let g:go_fmt_command = "goimports"
" vim-go extra mappings
au FileType go nmap <Leader>gd <Plug>(go-def-vertical)
au FileType go nmap <leader>gt <Plug>(go-test)

" Pencil
let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,md,vimwiki,tex,rst call pencil#init()
  autocmd FileType text                            call pencil#init({'wrap': 'hard'})
augroup END

set noautochdir

" nvim terminal mode
:tnoremap <Esc> <C-\><C-n>

" editorconfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" deocomplete
let g:python3_host_prog  = '/usr/bin/python3' " for neovim python-client
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
let g:deoplete#enable_smart_case = 1
set completeopt-=preview
" set completeopt-=noinsert,noselect
set completeopt+=longest,menuone
let g:deoplete#auto_completion_start_length = 0

let g:deoplete#ignore_sources = {}
let g:deoplete#ignore_sources._ = ["neosnippet"]
" let g:deoplete#ignore_sources._ = ['buffer', 'member', 'tag', 'file', 'neosnippet']

" deoplete-go
let g:deoplete#sources#go = 'vim-go'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#gocode_binary = '/Users/saulhoward/go/bin/gocode'

" Use partial fuzzy matches like YouCompleteMe
call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])

" <Tab> completion:
" 1. If popup menu is visible, select and insert next item
" 1a. if matches snippet, expand; if snipping, go to next bit
" 2. Otherwise, if preceding chars are whitespace, insert tab char
" 3. Otherwise, start manual autocomplete
inoremap <silent><expr><Tab> pumvisible() ? "\<C-n>"
    \ : neosnippet#expandable_or_jumpable() ? neosnippet#mappings#expand_or_jump_impl()
    \ : <SID>is_whitespace() ? "\<Tab>"
    \ : deoplete#mappings#manual_complete()

snoremap <silent><expr><Tab> pumvisible() ? "\<C-n>"
    \ : neosnippet#expandable_or_jumpable() ? neosnippet#mappings#expand_or_jump_impl()
    \ : <SID>is_whitespace() ? "\<Tab>"
    \ : deoplete#mappings#manual_complete()

inoremap <expr><S-Tab>  pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:is_whitespace() "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~? '\s'
endfunction "}}}

" neosnippets
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" rust rustlang racer
let g:racer_cmd = "/usr/bin/racer"
let $RUST_SRC_PATH="/usr/src/rust/src/"
let g:rustfmt_autosave = 1

" " vim-pad
" " let g:pad#set_mappings = 0
" " let g:pad#default_format = "vim-notes"
" let g:pad#dir="~/pads"
" let g:pad_default_file_extension = '.md'
" let g:pad#search_backend = "ag"
" let g:pad#open_in_split=0
" let g:pad#position=["list"]
" let g:pad#window_height=30
" let g:pad#window_width=50
" nmap <leader>ll <Plug>(pad-list)
