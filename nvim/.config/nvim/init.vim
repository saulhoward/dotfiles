" neovim rc by saul@saulhoward.com

" pull in vim defaults
source ~/.vimrc

" python
let g:python3_host_prog  = '/usr/local/bin/python3.6' " for neovim python-client
let g:python3_host_skip_check = 1
" let g:python_host_skip_check = 1

" install plugins (see vim-plug)

call plug#begin('~/.vim/plugged')

" style
Plug 'bling/vim-airline'
Plug 'rakr/vim-one'
Plug 'whatyouhide/vim-gotham'
Plug 'reedes/vim-colors-pencil'

" denite
Plug 'Shougo/neomru.vim'
Plug 'Shougo/denite.nvim'
Plug 'Jagua/vim-denite-ghq'

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
Plug 'glidenote/memolist.vim'

" git
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'airblade/vim-gitgutter'

" code
Plug 'sbdchd/neoformat'
Plug 'tomtom/tcomment_vim'
Plug 'fatih/vim-go', {'for' : 'go'}
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'pangloss/vim-javascript', {'for' : 'javascript'}
Plug 'mxw/vim-jsx', {'for' : 'javascript'}
Plug 'kchmck/vim-coffee-script', {'for' : 'coffee'}
Plug 'puppetlabs/puppet-syntax-vim', {'for' : 'puppet'}
Plug 'groenewege/vim-less', {'for' : 'less'}
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
function! DoRemote(arg)
  UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'zchee/deoplete-go', { 'for': 'go', 'do': 'make'}
Plug 'carlitux/deoplete-ternjs', {  'for': 'javascript', 'do': 'npm install -g tern' }

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
Plug 'christoomey/vim-tmux-navigator'

" layout
Plug 'cHoco/GoldenView.Vim'

call plug#end()

" plugin specific settings

" goldenview
let g:goldenview__enable_at_startup=1
let g:goldenview__enable_default_mapping=0
nmap <leader>s <Plug>GoldenViewSplit
nmap <silent> <C-M> <Plug>GoldenViewSwitchMain
nmap <silent> <C-T> <Plug>GoldenViewSwitchToggle
nmap <silent> <C-N> <Plug>GoldenViewNext
nmap <silent> <C-P> <Plug>GoldenViewPrevious

" airline settings
" remove separators
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_theme="one"
let g:airline#extensions#whitespace#enabled = 0
" tabline at top
let g:airline#extensions#tabline#enabled = 1

" denite
if executable('ag')
    call denite#custom#var('file_rec', 'command',
                \ ['ag', '--follow', '--nocolor', '--nogroup', '--ignore', 'vendor',
                \ '--ignore', '.git', '--ignore', '.bzr', '--ignore', '.hg',
                \ '--ignore', '.svn', '--ignore', 'node_modules', '--hidden', '-g', ''])

    call denite#custom#var('grep', 'command', ['ag'])
    call denite#custom#var('grep', 'default_opts',
                \ ['--smart-case', '--nocolor', '--nogroup', '--ignore',
                \ '.git', '--ignore', '.bzr', '--ignore', '.hg', '--ignore',
                \ '.svn', '--hidden'])
    call denite#custom#var('grep', 'recursive_opts', [])
	call denite#custom#var('grep', 'pattern_opt', ['--match'])
    call denite#custom#var('grep', 'final_opts', [])
    call denite#custom#var('grep', 'separator', ['--'])
endif

call denite#custom#source(
            \ 'file_mru', 'matchers', ['matcher_fuzzy'])
call denite#custom#source(
            \ 'file_rec', 'matchers', ['matcher_fuzzy'])
call denite#custom#source(
            \ 'file_mru', 'converters', ['converter_relative_word'])
call denite#custom#source(
            \ 'buffer,file_mru,file_rec,outline', 'sorters', ['sorter_sublime'])

nnoremap <leader>e :Denite -buffer-name=denite buffer<cr>
nnoremap <leader>f :Denite -buffer-name=denite file_rec<cr>
nnoremap <leader>r :Denite -buffer-name=denite file_mru<cr>
nnoremap <leader>g :Denite -buffer-name=denite grep<cr>
nnoremap <leader>o :Denite -buffer-name=denite outline<cr>

call denite#custom#map(
            \ 'insert',
            \ '<C-j>',
            \ '<denite:move_to_next_line>',
            \ 'noremap'
            \)
call denite#custom#map(
            \ 'insert',
            \ '<C-k>',
            \ '<denite:move_to_previous_line>',
            \ 'noremap'
            \)

" Copy file to clipboard
nmap <F3> :silent %w !xclip -selection clipboard<CR>

" vimwiki
let g:vimwiki_global_ext = 0
let g:vimwiki_folding = 1
let g:vimwiki_list = [{'path': '~/Sync/wiki/', 'template_path': '~/Sync/wiki/templates/',
          \ 'template_default': 'default', 'syntax': 'markdown', 'ext': '.md',
          \ 'path_html': '~/Sync/wiki/site_html/',
          \ 'custom_wiki2html': '/usr/local/lib/ruby/gems/2.3.0/gems/vimwiki_markdown-0.2.0/bin/vimwiki_markdown',
          \ 'template_ext': '.tpl', 'auto_export': 0}]
fun! SilentMakeHTML()
    if &ft =~ 'vimwiki'
        silent Vimwiki2HTML
    endif
endfun
autocmd BufWritePost *.md call SilentMakeHTML()
autocmd FileType vimwiki setl nonu

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
    let g:one_allow_italics = 1
    colorscheme one
    set guifont=Ubuntu\ Mono\ 14
    set guioptions-=m  "menu bar
    set guioptions-=T  "toolbar
    set guioptions+=LlRrb "scrollbars
    set guioptions-=LlRrb
    set lines=73 columns=260
else
    if (has("termguicolors"))
        set termguicolors " true colors
    endif
    let g:one_allow_italics = 1
    colorscheme one
endif

" Custom colors for denite
hi deniteMatchedChar ctermbg=NONE guifg=#e5c07b
hi deniteMatchedRange ctermbg=NONE guifg=#d19a66

function! s:denite_enter() 
    hi Cursorline guibg=#3e4452 guifg=#abb2bf
endfunction
function! s:denite_leave() 
    hi Cursorline guibg=#2c323c guifg=Normal
endfunction
au BufEnter denite call s:denite_enter()
au BufLeave denite call s:denite_leave()

" Goyo
function! s:goyo_enter()
    silent !tmux set status off
    DisableGoldenViewAutoResize
    set scrolloff=999
    set background=dark
    colorscheme gotham
    Limelight
endfunction
function! s:goyo_leave()
    silent !tmux set status on
    EnableGoldenViewAutoResize
    colorscheme one
    set scrolloff=2
    Limelight!
endfunction
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

nnoremap <leader>z :DisableGoldenViewAutoResize<cr>:Goyo<cr>

" JSX (for .js files as well)
let g:jsx_ext_required = 0

" Go
let g:go_fmt_command = "goimports"
let g:go_term_enabled = 1
let g:go_term_mode = "split"
let g:go_auto_type_info = 1
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
let g:deoplete#sources#go#gocode_binary = $HOME . '/go/bin/gocode'

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

" vim-rooter (cwd)
let g:rooter_silent_chdir = 1

" tmux
if has('nvim')
    nmap <BS> <C-W>h
endif

" memolist
let g:memolist_memo_suffix = "md"
let g:memolist_denite = 1
let g:memolist_path = $HOME . "/sync/memo"
noremap <Leader>mn :MemoNew<cr>
noremap <Leader>ml :MemoList<cr>
noremap <Leader>mg :MemoGrep<cr>

" neoformat
function! neoformat#formatters#javascript#prettier() abort
    return {
    \ 'exe': 'prettier',
    \ 'args': ['--stdin', '--bracket-spacing=false', '--single-quote'],
    \ 'stdin': 1,
    \ }
endfunction
augroup fmt
    autocmd!		
    autocmd BufWritePre *.js Neoformat
augroup END
