-- render-markdown.nvim: renders headings, code blocks, lists, tables, quotes
-- inline in the buffer while you edit. ASCII-safe config (have_nerd_font = false)
-- so nothing renders as glyph tofu; uses treesitter markdown parsers (installed).

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  -- No nerd font: use plain markers rather than nerd glyphs.
  heading = {
    icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
    width = 'full', -- background bars span the whole line
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

-- Terminals can't scale font size, so fake the heading hierarchy with colour +
-- bold + full-width background bars: loudest at H1, fading to fg-only by H6.
local function set_heading_hl()
  local levels = {
    { fg = '#f7768e', bg = '#3b2b33' }, -- H1  red     + bar
    { fg = '#ff9e64', bg = '#3a3129' }, -- H2  orange  + bar
    { fg = '#e0af68', bg = '#38342b' }, -- H3  yellow  + faint bar
    { fg = '#9ece6a' }, -- H4  green
    { fg = '#7dcfff' }, -- H5  cyan
    { fg = '#bb9af7' }, -- H6  purple
  }
  for i, c in ipairs(levels) do
    vim.api.nvim_set_hl(0, 'RenderMarkdownH' .. i, { fg = c.fg, bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH' .. i .. 'Bg', c.bg and { bg = c.bg } or {})
  end
end

set_heading_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_heading_hl })

-- Prose readability: wrap at word boundaries, not mid-word. `linebreak` is
-- ignored when `list` is on, so turn that off too; `breakindent` keeps wrapped
-- lines visually aligned under the first.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.list = false
    vim.opt_local.breakindent = true
  end,
})
