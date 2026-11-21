local M = {}
local api = vim.api
local applied, pending = {}, {}

local function nowrap_panels()
  for _, win in ipairs(api.nvim_list_wins()) do
    if vim.bo[api.nvim_win_get_buf(win)].filetype == 'gitsigns-diff' and vim.wo[win].wrap then
      vim.wo[win].wrap = false
    end
  end
end

-- Gitsigns bases are buffer-local, not window-local. Only change files displayed
-- in a review tab; never change the global default for other/new buffers.
local function review_signs(buf)
  if not api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then return end
  local base
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local review_base = vim.t[api.nvim_win_get_tabpage(win)].git_branch_changes_base
    if review_base then
      base = review_base
      vim.wo[win].signcolumn = 'yes'
      if win == api.nvim_get_current_win() then break end
    end
  end
  if not base or applied[buf] == base or pending[buf] then return end

  local gitsigns = require('gitsigns')
  -- A newly opened file may not have attached yet. GitSignsUpdate retries once
  -- attachment finishes, rather than silently losing its branch comparison.
  if not gitsigns.get_hunks(buf) then return end
  pending[buf] = true
  api.nvim_buf_call(buf, function()
    gitsigns.change_base(base, false, function(err)
      pending[buf] = nil
      if not api.nvim_buf_is_valid(buf) then return end
      if err then
        vim.notify('GitBranchChanges: ' .. err, vim.log.levels.ERROR)
      else
        applied[buf] = base
      end
    end)
  end)
end

-- Gitsigns has no public base getter. Read its pinned version's live cache so
-- manual change_base/reset_base commands cannot leave a stale statusline label.
-- If that internal API changes, omit the label rather than breaking the bar.
function M.statusline_base()
  local cache = package.loaded['gitsigns.cache']
  local entry = cache and cache.cache and cache.cache[api.nvim_get_current_buf()]
  if not entry or not entry.git_obj then return '' end
  local base = entry.file_mode and 'FILE' or entry.git_obj.revision
  if not base or base == ':0' then return '' end
  -- Git refs may contain %, which must be escaped in Neovim statuslines.
  return 'diff:' .. base:gsub('%%', '%%%%')
end

function M.setup()
  local group = api.nvim_create_augroup('dotfiles_git_review', { clear = true })
  api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = group,
    callback = function(ev)
      vim.schedule(function()
        nowrap_panels()
        review_signs(ev.buf)
      end)
    end,
  })
  api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'GitSignsUpdate',
    callback = function(ev)
      local buf = ev.data and ev.data.buffer
      if buf and api.nvim_buf_is_valid(buf) then
        -- A detach/reload loses the buffer-local base; reapply on attachment.
        if vim.b[buf].gitsigns_head == nil then applied[buf] = nil end
        vim.schedule(function() review_signs(buf) end)
      end
    end,
  })
  -- Gitsigns explicitly sets wrap on each tree render, including refreshes.
  -- Defer our override until it has finished updating the window.
  api.nvim_create_autocmd('OptionSet', {
    group = group,
    pattern = 'wrap',
    callback = function() vim.schedule(nowrap_panels) end,
  })
  api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev)
      applied[ev.buf], pending[ev.buf] = nil, nil
    end,
  })

  api.nvim_create_user_command('GitBranchChanges', function(opts)
    local base = opts.args ~= '' and opts.args or 'master'
    require('gitsigns').diff(base, nil, { diff = 'none' }, function(err)
      if err then
        vim.notify('GitBranchChanges: ' .. err, vim.log.levels.ERROR)
        return
      end
      local tab = api.nvim_get_current_tabpage()
      for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
        if vim.bo[api.nvim_win_get_buf(win)].filetype == 'gitsigns-diff' then
          vim.t[tab].git_branch_changes_base = base
          nowrap_panels()
          for _, review_win in ipairs(api.nvim_tabpage_list_wins(tab)) do
            local buf = api.nvim_win_get_buf(review_win)
            applied[buf] = nil
            review_signs(buf)
          end
          return
        end
      end
    end)
  end, {
    nargs = '?',
    desc = 'Browse changed files and gutter signs against master or an explicit base',
  })
end

return M
