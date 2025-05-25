-- Minimal Neovim config for WSL with nvim-tree, bufferline, vscode theme, C/C++ syntax, and 4-space indentation

-- Set up packer.nvim
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Initialize packer
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Packer itself
  use 'nvim-tree/nvim-tree.lua' -- File explorer
  use 'nvim-tree/nvim-web-devicons' -- Icons for nvim-tree
  use 'akinsho/bufferline.nvim' -- Buffer tabs
  use 'Mofiqul/vscode.nvim' -- VSCode theme
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- Syntax highlighting
  use { "akinsho/toggleterm.nvim", tag = '*' }
  -- LSP and completion plugins
  use 'neovim/nvim-lspconfig' -- LSP configurations
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer' -- Buffer completions
  use 'hrsh7th/cmp-path' -- Path completions
  use 'hrsh7th/cmp-cmdline' -- Cmdline completions

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Basic settings
vim.o.number = true -- Line numbers
vim.o.relativenumber = true -- Relative line numbers
vim.o.tabstop = 4 -- 4 spaces for tabs
vim.o.shiftwidth = 4 -- 4 spaces for indentation
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.smartindent = true -- Smart indentation
vim.o.termguicolors = true -- Enable true colors

-- Key mappings
vim.g.mapleader = ' ' -- Set leader key to space

-- nvim-tree setup
require('nvim-tree').setup {
  view = {
    width = 30,
    side = 'left',
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
}
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- bufferline setup
require('bufferline').setup {
  options = {
    diagnostics = 'nvim_lsp',
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        highlight = 'Directory',
        text_align = 'left',
      },
    },
  },
}
vim.api.nvim_set_keymap('n', '<leader>b', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>B', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })

-- Keymap to open horizontal terminal
vim.api.nvim_set_keymap('n', '<leader>t', ':belowright split | terminal<CR>', { noremap = true, silent = true })

-- Exit terminal mode with <Esc>
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Start terminal in insert mode when it opens
vim.cmd [[
  augroup Terminal
    autocmd!
    autocmd TermOpen * startinsert
  augroup END
]]

function _G.smart_quit()
  local buf_ft = vim.bo.filetype
  local buf_type = vim.bo.buftype

  if buf_ft == 'NvimTree' then
    -- Close nvim-tree window
    vim.cmd('NvimTreeClose')
    return
  elseif buf_type == 'terminal' then
    -- Force close terminal buffer
    vim.cmd('bd!') 
    return
  end

  -- Get list of buffers excluding NvimTree and unlisted buffers
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
      if ft ~= 'NvimTree' then
        table.insert(buffers, buf)
      end
    end
  end

  if #buffers <= 1 then
    -- If last buffer, quit all
    vim.cmd('qa')
  else
    -- Find current buffer index in the filtered buffer list
    local current_buf = vim.api.nvim_get_current_buf()
    local idx = nil
    for i, b in ipairs(buffers) do
      if b == current_buf then
        idx = i
        break
      end
    end

    -- Choose next buffer to switch to (try next buffer, else previous)
    local next_buf = nil
    if idx ~= nil then
      if idx < #buffers then
        next_buf = buffers[idx + 1]
      elseif idx == #buffers and #buffers > 1 then
        next_buf = buffers[idx - 1]
      end
    end

    -- Switch to next buffer
    if next_buf then
      vim.api.nvim_set_current_buf(next_buf)
    end

    -- Then delete current buffer
    vim.cmd('bd ' .. current_buf)
  end
end

-- Map Space + q to smart_quit
vim.api.nvim_set_keymap('n', '<leader>q', ':lua smart_quit()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>w', ':update<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:update<CR>a', { noremap = true, silent = true })

-- Copy to system clipboard with Ctrl+C in normal and visual modes
vim.api.nvim_set_keymap('n', '<C-c>', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })

-- Select all
vim.api.nvim_set_keymap('n', '<C-a>', 'ggVG', { noremap = true, silent = true })

-- vscode.nvim theme setup
require('vscode').setup {
  transparent = false,
  italic_comments = true,
  disable_nvimtree_bg = true,
}
vim.cmd [[colorscheme vscode]]

-- nvim-treesitter setup for C/C++ syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp' }, -- Install C and C++ parsers
  highlight = {
    enable = true, -- Enable syntax highlighting
    additional_vim_regex_highlighting = false, -- Use treesitter for highlighting
  },
}

-- Toggleterm setup
require("toggleterm").setup {
  direction = "horizontal",
  size = 10,
  open_mapping = [[<C-\>]],
  start_in_insert = true,
}

function _G.compile_and_run_cpp()
  local file = vim.fn.expand("%")
  local output = vim.fn.expand("%:r")
  local cmd = string.format("g++ %s -o %s && ./%s", file, output, output)

  -- Check all windows for a terminal buffer
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      -- Switch to terminal buffer and send command
      vim.api.nvim_set_current_win(win)
      vim.fn.chansend(vim.b.terminal_job_id, "clear && " .. cmd .. "\n")
      return
    end
  end

  -- If no terminal is open
  print("No terminal is open! Open a terminal first with <leader>t")
end

vim.api.nvim_set_keymap('n', '<leader>r', ':lua compile_and_run_cpp()<CR>', { noremap = true, silent = true })

-- LSP and Completion setup
-- Set up nvim-cmp for autocompletion
local cmp = require('cmp')
cmp.setup {
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

-- Set up LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Set up clangd LSP
require('lspconfig').clangd.setup {
  capabilities = capabilities,
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  cmd = { 'clangd', '--background-index' }, -- Ensure clangd is installed
}

-- LSP keybindings
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
