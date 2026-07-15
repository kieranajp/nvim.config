-- <leader>gy: copy a commit-pinned GitHub permalink for the current line (normal)
-- or the selected range (visual) to the system clipboard. Shells out to `gh browse`,
-- which handles ssh/https remote parsing. No plugin needed.

local function yank_permalink()
  local abs = vim.fn.expand '%:p'
  if abs == '' then
    return vim.notify('No file in this buffer', vim.log.levels.WARN)
  end
  local dir = vim.fn.fnamemodify(abs, ':h')

  local function git(args)
    local r = vim.system(vim.list_extend({ 'git', '-C', dir }, args), { text = true }):wait()
    return (r.stdout or ''):gsub('%s+$', ''), r.code
  end

  local root, code = git { 'rev-parse', '--show-toplevel' }
  if code ~= 0 then
    return vim.notify('Not inside a git repo', vim.log.levels.WARN)
  end
  local sha = git { 'rev-parse', 'HEAD' }
  local relpath = abs:sub(#root + 2) -- strip "root/"

  -- line('v') is the visual anchor, line('.') the cursor; equal in normal mode.
  local a, b = vim.fn.line 'v', vim.fn.line '.'
  if a > b then
    a, b = b, a
  end
  local loc = a == b and (':' .. a) or (':' .. a .. '-' .. b)

  local res = vim.system({ 'gh', 'browse', '-n', relpath .. loc, '--commit=' .. sha }, { cwd = root, text = true }):wait()
  if res.code ~= 0 then
    return vim.notify('gh browse failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
  end
  local url = (res.stdout or ''):gsub('%s+$', '')
  vim.fn.setreg('+', url)
  vim.notify('Copied: ' .. url)
end

vim.keymap.set({ 'n', 'x' }, '<leader>gy', yank_permalink, { desc = '[G]it: [Y]ank GitHub permalink' })
