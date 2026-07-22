# nvim.config

My Neovim config. A lightly-tuned fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
(the `vim.pack` flavour, needs Neovim ≥ 0.12), kept as a single documented `init.lua`
plus a few extras under `lua/custom/plugins/`.

## What I changed from vanilla kickstart

- **LSP** enabled for Go (`gopls`), PHP (`intelephense`), JS/TS (`ts_ls`)
- **Treesitter** parsers for go/php/js/ts/tsx added to the install list
- **[noice.nvim](https://github.com/folke/noice.nvim)** — centred cmdline, prettier messages & LSP hover
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)** — tab bar across the top
- **mini.files** toggle on `<leader>e`, with `<CR>` bound to open/enter
- Quicker binds: `<C-p>`/`<leader>p` find files, `<leader>/` grep project, `<S-h>`/`<S-l>` cycle buffers

## Install

```sh
git clone git@github.com:kieranajp/nvim.config.git ~/.config/nvim
nvim   # plugins install on first launch
```

Needs `rg`, `fd`, and the `tree-sitter` CLI on PATH. Nerd-font icons are on
(`vim.g.have_nerd_font = true`); assumes a Nerd Font is selected in the terminal.

## Credit

Base config: [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), MIT licensed (see `LICENSE.md`).
