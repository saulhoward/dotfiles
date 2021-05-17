scriptencoding utf-8
source $HOME/.vimrc

let g:polyglot_disabled = ['markdown']
source $HOME/.config/nvim/plugins.vim

let g:python3_host_prog = "/Users/saulhoward/.pyenv/versions/3.7.9/bin/python3.7"

" # general vim settings

" splits
nmap <leader>s <C-w>s
nmap <leader>v <C-w>v

" move around windows with ctrl key
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l

" date insert
nmap <F3> i<C-R>=strftime("%Y/%m/%d %a %I:%M %p")<CR><Esc>
imap <F3> <C-R>=strftime("%Y/%m/%d %a %I:%M %p")<CR>

" # PLUGIN SETUP

" vim-rooter
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['.git']

" ## goldenview
let g:goldenview__enable_at_startup=1
let g:goldenview__enable_default_mapping=0

" denite

call denite#custom#option('default', {
      \ 'prompt': '❯'
      \ })

call denite#custom#var('file/rec', 'command',
      \ ['fd', '-H', '--full-path'])
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
      \ ['--hidden', '--vimgrep', '--smart-case'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

autocmd FileType denite call s:denite_settings()

function! s:denite_settings() abort
  nnoremap <silent><buffer><expr> <CR>
        \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> <C-v>
        \ denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> d
        \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
        \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> <Esc>
        \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> q
        \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
        \ denite#do_map('open_filter_buffer')
endfunction

autocmd FileType denite-filter call s:denite_filter_settings()

function! s:denite_filter_settings() abort
  nmap <silent><buffer> <Esc> <Plug>(denite_filter_quit)
endfunction

nnoremap <leader>f :<C-u>Denite file/rec -start-filter<CR>
nnoremap <leader>g :<C-u>Denite grep:.<CR>
nnoremap <leader>r :<C-u>Denite file_mru<CR>

hi link deniteMatchedChar Special

" defx
nnoremap <leader>d :Defx<cr>
autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
    " Define mappings
    nnoremap <silent><buffer><expr> <CR>
                \ defx#do_action('open')
    nnoremap <silent><buffer><expr> c
                \ defx#do_action('copy')
    nnoremap <silent><buffer><expr> m
                \ defx#do_action('move')
    nnoremap <silent><buffer><expr> p
                \ defx#do_action('paste')
    nnoremap <silent><buffer><expr> l
                \ defx#do_action('open')
    nnoremap <silent><buffer><expr> E
                \ defx#do_action('open', 'vsplit')
    nnoremap <silent><buffer><expr> P
                \ defx#do_action('open', 'pedit')
    nnoremap <silent><buffer><expr> K
                \ defx#do_action('new_directory')
    nnoremap <silent><buffer><expr> N
                \ defx#do_action('new_file')
    nnoremap <silent><buffer><expr> d
                \ defx#do_action('remove')
    nnoremap <silent><buffer><expr> r
                \ defx#do_action('rename')
    nnoremap <silent><buffer><expr> x
                \ defx#do_action('execute_system')
    nnoremap <silent><buffer><expr> yy
                \ defx#do_action('yank_path')
    nnoremap <silent><buffer><expr> .
                \ defx#do_action('toggle_ignored_files')
    nnoremap <silent><buffer><expr> h
                \ defx#do_action('cd', ['..'])
    nnoremap <silent><buffer><expr> ~
                \ defx#do_action('cd')
    nnoremap <silent><buffer><expr> q
                \ defx#do_action('quit')
    nnoremap <silent><buffer><expr> <Space>
                \ defx#do_action('toggle_select') . 'j'
    nnoremap <silent><buffer><expr> *
                \ defx#do_action('toggle_select_all')
    nnoremap <silent><buffer><expr> j
                \ line('.') == line('$') ? 'gg' : 'j'
    nnoremap <silent><buffer><expr> k
                \ line('.') == 1 ? 'G' : 'k'
    nnoremap <silent><buffer><expr> <C-l>
                \ defx#do_action('redraw')
    nnoremap <silent><buffer><expr> <C-g>
                \ defx#do_action('print')
    nnoremap <silent><buffer><expr> cd
                \ defx#do_action('change_vim_cwd')
endfunction

" === Coc.nvim === "
" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

"Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Wrap in try/catch to avoid errors on initial install before plugin is available
try

" === Vim airline ==== "
" Enable extensions
let g:airline_extensions = ['branch', 'hunks', 'coc']

" Update section z to just have line number
let g:airline_section_z = airline#section#create(['linenr'])

" Do not draw separators for empty sections (only for the active window) >
let g:airline_skip_empty_sections = 1

" Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail'

" Custom setup that removes filetype/whitespace from default vim airline bar
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'z', 'warning', 'error']]

let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'

let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

" Configure error/warning section to use coc.nvim
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

" Hide the Nerdtree status line to avoid clutter
let g:NERDTreeStatusline = ''

" Disable vim-airline in preview mode
let g:airline_exclude_preview = 1

" Enable caching of syntax highlighting groups
let g:airline_highlighting_cache = 1

" Define custom airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '❮'
let g:airline_right_sep = '❯'

" Don't show git changes to current file in airline
let g:airline#extensions#hunks#enabled=0

catch
  echo 'Airline not installed. It should work after running :PlugInstall'
endtry

" === echodoc === "
" Enable echodoc on startup
let g:echodoc#enable_at_startup = 1
set noshowmode

" === vim-javascript === "
" Enable syntax highlighting for JSDoc
let g:javascript_plugin_jsdoc = 1

" === vim-jsx === "
" Highlight jsx syntax even in non .jsx files
let g:jsx_ext_required = 0

" === javascript-libraries-syntax === "
let g:used_javascript_libs = 'underscore,requirejs,chai,jquery'

" === Signify === "
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '-'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change            = '•'

" todo
nmap <leader>n :find ~/Dropbox/lists/todo.md<CR>

" markdown
" let g:mkdx#settings     = { 'highlight': { 'enable': 1 },
"             \ 'enter': { 'shift': 1 },
"             \  }

" # colors

" has to be after bundle because theme is loaded then
syntax on

set background=dark
if has("gui_running")
    let g:palenight_terminal_italics=1
    colorscheme palenight
    " set guifont=Ubuntu\ Mono\ 14
    set guioptions-=m  "menu bar
    set guioptions-=T  "toolbar
    set guioptions+=LlRrb "scrollbars
    set guioptions-=LlRrb
    set lines=73 columns=260
else
    if (has("termguicolors"))
        set termguicolors " true colors
    endif
    let g:palenight_terminal_italics=1
    let g:airline_theme = "palenight"
    colorscheme palenight
endif

" Custom colors for denite
hi deniteMatchedChar ctermbg=NONE guifg=#e5c07b
hi deniteMatchedRange ctermbg=NONE guifg=#d19a66
hi deniteCursorline guibg=#3e4452 guifg=Normal

" goyo
function! s:goyo_enter()
    silent !tmux set status off
    " DisableGoldenViewAutoResize
    set scrolloff=999
    set background=light
    colorscheme one
    Limelight
endfunction
function! s:goyo_leave()
    silent !tmux set status on
    " EnableGoldenViewAutoResize
    set background=dark
    colorscheme palenight
    set scrolloff=2
    Limelight!
endfunction
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

nnoremap <leader>z :Goyo<cr>

" neoformat
" let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_html = ['tidy']

" ale lint

" let g:ale_sign_error = '⨉'
" let g:ale_sign_warning = '⚠'
" let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '']
" let g:ale_lint_on_text_changed = 0
" let g:ale_lint_on_save = 1
" cycle through location list
" nnoremap <leader>n <Plug>(ale_next_wrap)
let g:ale_linters = {
            \'javascript': ['prettier'],
            \'javascript.jsx': ['prettier'],
            \'vim': [],
            \'scss': [],
            \'rst': [],
            \'json': [],
            \'markdown': [],
            \'ruby': [],
            \}

let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'css': ['prettier'],
\   'python': ['black'],
\}
let g:ale_fix_on_save = 1

" vista
let g:vista_icon_indent = ["▸ ", ""]
let g:vista_default_executive = 'coc'
nnoremap <leader>o :Vista!!<cr>

" markdown mxdx
" let g:mkdx#settings = { 'enter': { 'enable': 1 } }
