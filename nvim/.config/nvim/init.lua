-- Shared settings live in ~/.vimrc (the vim stow package) so plain vim gets them too.
local vimrc = vim.fn.expand('~/.vimrc')
if vim.uv.fs_stat(vimrc) then
  vim.cmd.source(vimrc)
end

vim.o.clipboard = 'unnamedplus'
vim.o.guifont = 'TX-02 SemiCondensed:h15'

-- Plugins (built-in vim.pack; versions pinned in nvim-pack-lock.json)
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/datsfilipe/vesper.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

-- Theme
require('vesper').setup({
  italics = { comments = false, keywords = false, functions = false, strings = false, variables = false },
  -- bluish background; vesper's own #101010 background becomes the accent for
  -- the colorcolumn, current line, gutter, statusline and cmdline (overrides
  -- replace whole groups, so the fgs are vesper's fgLineNr, white and fg)
  palette_overrides = { bg = '#12141a' },
  overrides = {
    ColorColumn = { bg = '#101010' },
    CursorLine = { bg = '#101010' },
    LineNr = { fg = '#505050', bg = '#101010' },
    CursorLineNr = { fg = '#ffffff', bg = '#101010' },
    SignColumn = { bg = '#101010' },
    StatusLine = { fg = '#cccccc', bg = '#101010' },
    MsgArea = { fg = '#cccccc', bg = '#101010' },
    ModeMsg = { fg = '#cccccc' }, -- vesper links this to Normal, whose bg would box "-- INSERT --"
    Visual = { bg = '#2c3240' }, -- vesper mixes its bg 70% towards white (#656565), washing out text
  },
})
vim.cmd.colorscheme('vesper')

-- Treesitter: nvim bundles c, lua, markdown, vim and vimdoc; install the rest
-- (building parsers needs the tree-sitter CLI)
if vim.fn.executable('tree-sitter') == 1 then
  require('nvim-treesitter').install({
    'elixir', 'go', 'html', 'javascript', 'python', 'typescript', 'zig',
  })
end
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- LSP: server configs come from nvim-lspconfig; the servers themselves from the nix flake
vim.lsp.enable({ 'gopls', 'pyright', 'ts_ls', 'zls' })
-- gd jumps to the LSP definition when the server supports it, otherwise vim's builtin gd
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf })
    end
  end,
})

-- Fuzzy finding (fzf binary comes from the nix flake)
require('fzf-lua').setup({})
vim.keymap.set('n', '<leader>f', '<cmd>FzfLua files<cr>')
vim.keymap.set('n', '<leader>g', '<cmd>FzfLua live_grep<cr>')
vim.keymap.set('n', '<leader>b', '<cmd>FzfLua buffers<cr>')
vim.keymap.set('n', '<leader>h', '<cmd>FzfLua helptags<cr>')
vim.keymap.set('n', '<leader>/', '<cmd>FzfLua resume<cr>')
