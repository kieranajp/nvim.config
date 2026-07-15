-- bufferline.nvim: VS Code-style tab bar across the top, one entry per buffer.
-- Configured ASCII-safe because have_nerd_font = false (no glyph tofu).
-- Added the vim.pack way to match the rest of this config.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'akinsho/bufferline.nvim' }

vim.o.termguicolors = true -- bufferline needs true colour for its highlights

require('bufferline').setup {
  options = {
    show_buffer_icons = false, -- no nerd font -> no filetype icons
    buffer_close_icon = 'x',
    modified_icon = '●',
    close_icon = 'x',
    left_trunc_marker = '<',
    right_trunc_marker = '>',
    separator_style = { '│', '│' },
    diagnostics = 'nvim_lsp', -- show LSP error/warn counts on each buffer
  },
}

-- Cycle buffers along the bar. Shift-h / Shift-l = left / right.
vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
