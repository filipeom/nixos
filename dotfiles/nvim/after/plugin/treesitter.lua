require('nvim-treesitter').setup {
  install_dir = vim.fn.expand('$HOME/.local/share/nvim/site/pack/hm/start/nvim-treesitter-grammars/')
}

vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function()
    local success = pcall(vim.treesitter.start)
    if success then
      vim.wo[0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0].foldmethod = 'expr'
    else
      vim.opt_local.foldmethod = "syntax"
    end
  end
})
