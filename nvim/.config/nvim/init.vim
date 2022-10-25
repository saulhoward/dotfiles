scriptencoding utf-8
source $HOME/.vimrc

" # PLUGINS
call plug#begin('~/.config/nvim/plugged')
" Plug 'numToStr/Comment.nvim', Cond(!exists('g:vscode'))
Plug 'editorconfig/editorconfig-vim'
call plug#end()

" splits
nmap <leader>s <C-w>s
nmap <leader>v <C-w>v

" move around windows with ctrl key
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l


if exists('g:vscode')
  xmap gc VSCodeCommentary
  nmap gc VSCodeCommentary
  omap gc VSCodeCommentary
  nmap gcc VSCodeCommentaryLine
else
  " lua require('Comment').setup()
endif

