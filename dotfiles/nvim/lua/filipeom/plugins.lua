-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use 'EdenEast/nightfox.nvim'
  use { 'nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' } }
  use 'nvim-treesitter/playground'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-commentary'
  use 'mason-org/mason.nvim'
  -- use {
  --   'VonHeikemen/lsp-zero.nvim',
  --   branch = 'v2.x',
  --   requires = {
  --     -- LSP Support
  --     { 'neovim/nvim-lspconfig' }, -- Required
  --     {                          -- Optional
  --       'williamboman/mason.nvim',
  --       run = function()
  --         pcall(vim.cmd, 'MasonUpdate')
  --       end,
  --     },
  --     { 'williamboman/mason-lspconfig.nvim' }, -- Optional

  --     -- Autocompletion
  --     -- Plug 'hrsh7th/cmp-nvim-lsp'
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/cmp-cmdline' }
  use { 'hrsh7th/nvim-cmp' }   -- Required
  use { 'hrsh7th/cmp-nvim-lsp' } -- Required
  use { 'hrsh7th/cmp-vsnip' }
  use { 'hrsh7th/vim-vsnip' }

  --   }
  -- }
  use 'romgrk/barbar.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use 'wasp-platform/ecmasl-vim'
end)
