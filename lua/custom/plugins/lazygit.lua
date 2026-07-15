-- <leader>gg: open lazygit in a floating terminal. Quitting lazygit (q) closes
-- the float automatically. No plugin — just a native float + terminal job.

local function open_lazygit()
  if vim.fn.executable 'lazygit' == 0 then
    return vim.notify('lazygit not found on PATH', vim.log.levels.ERROR)
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' lazygit ',
    title_pos = 'center',
  })

  vim.fn.jobstart('lazygit', {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end,
  })
  vim.cmd.startinsert() -- hand keystrokes straight to lazygit
end

vim.keymap.set('n', '<leader>gg', open_lazygit, { desc = '[G]it: lazy[G]it' })
