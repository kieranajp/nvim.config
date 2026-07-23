-- Floating fish terminals in numbered slots, opened at the current file's git
-- root (so your aliases/abbrs load). Sessions persist across hide/show.
--
--   <leader>g1 .. <leader>g9  open/focus that slot (creates it if empty;
--                             press the visible slot again to hide the float)
--   <leader>g                 pick from the active terminals by title
--
-- Leave `go run main.go` in slot 1, pop open slot 2 for git. No plugin.

local state = { win = -1, terms = {}, active = nil } -- terms[slot] = buf

-- Prefer fish so interactive config (aliases/abbrs) loads; fall back to $SHELL.
local shell = vim.fn.executable 'fish' == 1 and 'fish' or vim.o.shell

local function repo_root()
  local dir = vim.fn.expand '%:p:h'
  if dir == '' then dir = vim.fn.getcwd() end
  local r = vim.system({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  return r.code == 0 and (r.stdout:gsub('%s+$', '')) or dir
end

local function float_open(buf, slot)
  if vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
  local w = math.floor(vim.o.columns * 0.9)
  local h = math.floor(vim.o.lines * 0.9)
  state.win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = 'minimal',
    border = 'rounded',
    title = string.format(' terminal %d ', slot),
    title_pos = 'center',
  })
  state.active = slot
  vim.cmd.startinsert()
end

local function focus(slot)
  -- Already showing this slot? Hide the float (buffer + shell job kept alive).
  if state.active == slot and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = -1
    return
  end

  local buf = state.terms[slot]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    float_open(buf, slot) -- reshow existing session
  else
    buf = vim.api.nvim_create_buf(false, true)
    state.terms[slot] = buf
    float_open(buf, slot) -- must focus the buffer before starting the term job
    vim.fn.jobstart(shell, {
      term = true,
      cwd = repo_root(),
      on_exit = function()
        state.terms[slot] = nil
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        if state.active == slot and vim.api.nvim_win_is_valid(state.win) then
          vim.api.nvim_win_close(state.win, true)
          state.win, state.active = -1, nil
        end
      end,
    })
  end
end

-- The terminal's live OSC title (fish sets it to the running command / cwd).
local function title(buf)
  local ok, t = pcall(vim.api.nvim_buf_get_var, buf, 'term_title')
  if ok and t and t ~= '' then return t end
  return vim.api.nvim_buf_get_name(buf)
end

local function picker()
  local items = {}
  for slot = 1, 9 do
    local buf = state.terms[slot]
    if buf and vim.api.nvim_buf_is_valid(buf) then
      items[#items + 1] = { slot = slot, label = string.format('%d: %s', slot, title(buf)) }
    end
  end
  if #items == 0 then
    focus(1) -- nothing running yet, just open the first
    return
  end
  vim.ui.select(items, {
    prompt = 'Terminals',
    format_item = function(i) return i.label end,
  }, function(choice)
    if choice then focus(choice.slot) end
  end)
end

vim.keymap.set('n', '<leader>g', picker, { desc = '[G]it/terminal picker' })
for n = 1, 9 do
  vim.keymap.set('n', '<leader>g' .. n, function() focus(n) end, { desc = 'Terminal ' .. n })
end
-- From inside a terminal, Esc to normal mode (<C-\><C-n>), then use <leader>g…
vim.keymap.set('t', '<C-\\><C-n>', '<C-\\><C-n>', { desc = 'Terminal -> normal mode' })
