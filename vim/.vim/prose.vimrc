" Prose settings shared by vim/nvim (markdown, text and fountain buffers) and
" Obsidian (sourced by obsidian/.obsidian.vimrc). Obsidian's vim emulation
" only understands plain map and set lines, so keep to those: vim applies each
" line to the prose buffer only, adding <buffer> to the maps.

setlocal textwidth=80

" = hard-wraps to textwidth (rejoining lines first, so edited text reflows)
" instead of reindenting; == reflows the whole paragraph
nnoremap = gw
vnoremap = gw
" Obsidian runs the = map without waiting for ==, so == there is gw then =,
" which this turns into gwap (it also makes d=, y= etc. act on the paragraph)
onoremap = ap
" vim: overrides the global == (comment reflow); Obsidian never reaches it
nnoremap == gwap
