-- Launching `nvim`, `nvim .` or `nvim <dir>` opens the file picker (find_files)
-- scoped to that folder, instead of netrw's directory listing / an empty buffer.
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() > 1 then return end -- opened several files: leave them be
    local arg = vim.fn.argv(0)
    local opened_dir = arg ~= '' and vim.fn.isdirectory(arg) == 1
    local no_file = arg == '' and vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) == ''
    if not (opened_dir or no_file) then return end -- a real file was opened

    if opened_dir then
      vim.cmd.cd(arg)
      vim.cmd.enew() -- swap the netrw dir buffer for a blank one
    end
    -- Defer so it runs after startup settles.
    vim.schedule(function() require('telescope.builtin').find_files() end)
  end,
})
