-- <leader>gg: toggle a floating terminal running fish (so your aliases and
-- abbreviations load), opened at the current file's git root. The shell session
-- persists across toggles — hide and reshow without losing history or state.
-- Just type git the way you always do. No plugin.

local state = { buf = -1, win = -1 }

-- Prefer fish so interactive config (aliases/abbrs) loads; fall back to $SHELL.
local shell = vim.fn.executable 'fish' == 1 and 'fish' or vim.o.shell

local function repo_root()
  local dir = vim.fn.expand '%:p:h'
  if dir == '' then dir = vim.fn.getcwd() end
  local r = vim.system({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  return r.code == 0 and (r.stdout:gsub('%s+$', '')) or dir
end

local function open_win(buf)
  local w = math.floor(vim.o.columns * 0.9)
  local h = math.floor(vim.o.lines * 0.9)
  return vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' terminal ',
    title_pos = 'center',
  })
end

local function toggle()
  -- Visible? Hide it (window closed, buffer + shell job kept alive).
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = -1
    return
  end

  if vim.api.nvim_buf_is_valid(state.buf) then
    state.win = open_win(state.buf) -- reshow the existing session
  else
    state.buf = vim.api.nvim_create_buf(false, true)
    state.win = open_win(state.buf) -- must focus the buffer before starting the term job
    vim.fn.jobstart(shell, {
      term = true,
      cwd = repo_root(),
      on_exit = function()
        if vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
        if vim.api.nvim_buf_is_valid(state.buf) then vim.api.nvim_buf_delete(state.buf, { force = true }) end
        state.buf, state.win = -1, -1
      end,
    })
  end
  vim.cmd.startinsert()
end

vim.keymap.set('n', '<leader>gg', toggle, { desc = '[G]it/terminal float (toggle)' })
-- From inside the terminal, hide without killing the session: Esc to normal, then toggle.
vim.keymap.set('t', '<C-\\><C-n>', '<C-\\><C-n>', { desc = 'Terminal -> normal mode' })
