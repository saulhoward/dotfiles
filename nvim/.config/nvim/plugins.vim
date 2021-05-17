" # PLUGINS

call plug#begin('~/.config/nvim/plugged')

" ## Editing Plugins
Plug 'ntpeters/vim-better-whitespace'
Plug 'rstacruz/vim-closer'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'christoomey/vim-tmux-navigator'
Plug 'Shougo/denite.nvim', { 'do' : ':UpdateRemotePlugins' }
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neomru.vim'
Plug 'Shougo/echodoc.vim'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'

" ## Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" ## markdown
Plug 'SidOfc/mkdx' " has to come before polyglot

" ## Code
Plug 'dense-analysis/ale'
Plug 'sbdchd/neoformat'
Plug 'liuchengxu/vista.vim'
Plug 'tomtom/tcomment_vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'fatih/vim-go', {'for': 'go', 'do': ':GoUpdateBinaries' }
Plug 'sheerun/vim-polyglot'
Plug 'heavenshell/vim-jsdoc'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'ap/vim-css-color', {'for': 'css'}
" Plug 'rust-lang/rust.vim', {'for': 'rust'}
" Plug 'othree/yajs.vim'

" ## grep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ -S
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" ## misc
Plug 'airblade/vim-rooter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Konfekt/FastFold'

" ## writing
Plug 'vim-scripts/fountain.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'reedes/vim-pencil'

" ## layout
Plug 'RobertAudi/GoldenView.vim'
Plug 'dstein64/vim-win'

" ## colors
Plug 'drewtempelmeyer/palenight.vim'
Plug 'desmap/slick'

" ## status
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Initialize plugin system
call plug#end()
