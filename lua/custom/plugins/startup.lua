-- Disable netrw's directory listing so it never hijacks the window on launch.
-- (mini.files is the explorer; nvim 0.10+ handles gx/open-url natively.)
-- Must be set before netrw loads — this file is required during init.lua, which
-- runs before runtime plugins are sourced, so we're early enough.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Launching `nvim`, `nvim .` or `nvim <dir>` opens the file picker (find_files)
-- scoped to that folder, instead of an empty buffer.
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() > 1 then return end -- opened several files: leave them be
    local arg = vim.fn.argv(0)
    local opened_dir = arg ~= '' and vim.fn.isdirectory(arg) == 1
    local no_file = arg == '' and vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) == ''
    if not (opened_dir or no_file) then return end -- a real file was opened

    if opened_dir then
      vim.cmd.cd(arg)
      vim.cmd.enew() -- drop the empty dir-named buffer
    end
    -- Defer so it runs after startup settles.
    vim.schedule(function() require('telescope.builtin').find_files() end)
  end,
})
