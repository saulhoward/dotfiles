scriptencoding utf-8
source $HOME/.vimrc

" # PLUGINS
call plug#begin('~/.config/nvim/plugged')
Plug 'tomtom/tcomment_vim'
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

