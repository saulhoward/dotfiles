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
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

-- Theme
require('vesper').setup({
  italics = { comments = false, keywords = false, functions = false, strings = false, variables = false },
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
