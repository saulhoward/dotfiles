vim.cmd.colorscheme("vesper")
vim.opt.guifont = { "TX-02 SemiCondensed"," h15" }
 
vim.opt.clipboard = 'unnamedplus' -- use system keyboard for yank
 
vim.opt.number = true                 -- set line numbers
-- vim.opt.relativenumber = true     -- use relative line numbers
 
-- set tab size to 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
 
vim.opt.wrap = false
 
vim.opt.incsearch = true -- incremental search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.completeopt = "menuone,noselect"

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1
vim.opt.scrolloff = 10


vim.opt.encoding = "UTF-8"
------


-- Behaviour

-- opt.hidden = true
-- opt.errorbells = false
-- --opt.backspace = "indent, eol, start" 
-- opt.splitright = true
-- opt.splitbelow = true
-- opt.autochdir = false
-- opt.iskeyword:append( 'a' )
-- opt.clipboard: append( "unnamedplus")
-- opt.modifiable = true
-- --opt.guicursor = true 
