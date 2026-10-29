" Obsidian vimrc (obsidian-vimrc-support plugin). Obsidian only reads files
" inside the vault, so this file and vim/.vim/prose.vimrc are symlinked into the
" vault's unsynced .local folder; see the README.

" Shared with vim's markdown buffers
source .local/prose.vimrc

" Same as ~/.vimrc (which Obsidian can't read)
nnoremap Y y$

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk

" Yank to system clipboard
set clipboard=unnamed

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand app:go-back
nmap <C-o> :back<CR>
exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>

" Make o and O respect context
exmap blankBelow obcommand obsidian-editor-shortcuts:insertLineBelow
exmap blankAbove obcommand obsidian-editor-shortcuts:insertLineAbove
nmap o :blankBelow<CR>i
nmap O :blankAbove<CR>i
