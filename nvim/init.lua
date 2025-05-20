-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  underline = false,
  update_in_insert = false,
})
