-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("nvim-tree").setup({
  filters = {
    dotfiles = false, -- show dotfiles (hidden files)
  },
})
