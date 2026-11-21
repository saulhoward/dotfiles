-- Vesper's charcoal and orange palette, matching the gutter/statusline bg.
local colors = {
  bg = '#101010',
  surface = '#232323',
  fg = '#cccccc',
  muted = '#7d7d7d',
  orange = '#FFCFA8',
  yellow = '#FFC799',
  red = '#FF8080',
  white = '#FFFFFF',
}

local function mode(accent)
  return {
    a = { fg = colors.bg, bg = accent, gui = 'bold' },
    b = { fg = colors.fg, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  }
end

return {
  options = {
    theme = {
      normal = mode(colors.orange),
      insert = mode(colors.orange),
      visual = mode(colors.white),
      replace = mode(colors.red),
      command = mode(colors.yellow),
      terminal = mode(colors.orange),
      inactive = {
        a = { fg = colors.muted, bg = colors.bg },
        b = { fg = colors.muted, bg = colors.bg },
        c = { fg = colors.muted, bg = colors.bg },
      },
    },
    icons_enabled = false,
    component_separators = '|',
    section_separators = '',
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      {
        require('git_review').statusline_base,
        color = { fg = colors.orange, gui = 'bold' },
      },
      {
        'diff',
        -- Reuse Gitsigns' live buffer counts, including unsaved changes.
        source = function()
          local status = vim.b.gitsigns_status_dict
          if status then
            return { added = status.added, modified = status.changed, removed = status.removed }
          end
        end,
        symbols = { added = '+', modified = '~', removed = '-' },
        diff_color = {
          added = { fg = colors.orange },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
      },
    },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = {
      {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.orange },
          hint = { fg = colors.muted },
        },
      },
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'location' },
  },
}
