-- noice.nvim: floats the `:` cmdline into the middle of the screen, prettifies
-- messages/popups and LSP hover. The biggest "feels like Helix" hit.
-- Added the vim.pack way to match the rest of this kickstart config.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MunifTanjim/nui.nvim', -- UI component lib noice depends on
  gh 'rcarriga/nvim-notify', -- toast-style notifications, top-right
  gh 'folke/noice.nvim',
}

require('noice').setup {
  lsp = {
    -- Render LSP markdown (hover / signature help) through noice.
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
    },
  },
  presets = {
    bottom_search = true, -- keep `/` search at the bottom, classic vim
    command_palette = true, -- cmdline + completion menu together, centred
    long_message_to_split = true, -- long :messages go to a split, not a wall
    lsp_doc_border = true,
  },
}
