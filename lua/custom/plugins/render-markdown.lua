-- render-markdown.nvim: renders headings, code blocks, lists, tables, quotes
-- inline in the buffer while you edit. ASCII-safe config (have_nerd_font = false)
-- so nothing renders as glyph tofu; uses treesitter markdown parsers (installed).

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  -- No nerd font: use plain markers rather than nerd glyphs.
  heading = {
    icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
  },
  bullet = {
    icons = { '•', '◦', '▸', '▹' },
  },
  checkbox = {
    unchecked = { icon = '[ ] ' },
    checked = { icon = '[x] ' },
  },
  code = {
    -- Keep code blocks readable without needing language icons.
    sign = false,
    width = 'block',
    left_pad = 1,
    right_pad = 1,
  },
}
