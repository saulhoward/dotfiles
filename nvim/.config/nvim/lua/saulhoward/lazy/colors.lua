return {
	{
    'datsfilipe/vesper.nvim',
		lazy = false,
		priority = 1000,
		name = "vesper",
		config = function ()
      vim.cmd([[colorscheme vesper]])
      require('vesper').setup({
        transparent = false, -- Boolean: Sets the background to transparent
        italics = {
          comments = false, -- Boolean: Italicizes comments
          keywords = false, -- Boolean: Italicizes keywords
          functions = false, -- Boolean: Italicizes functions
          strings = false, -- Boolean: Italicizes strings
          variables = false, -- Boolean: Italicizes variables
        },
        overrides = {}, -- A dictionary of group names, can be a function returning a dictionary or a table.
        palette_overrides = {}
      })
		end
	},
}
