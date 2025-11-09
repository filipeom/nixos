vim.lsp.enable({
  'basedpyright',
  'lua_ls',
  'ocamllsp',
  'rust_analyzer',
  'texlab',
  'tinymist',
  'marksman'
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function (event)
    local opts = { buffer = event.buf, remap = false }

    vim.keymap.set('n', 'T', function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, opts)
    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set('n', '<F2>', function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set('n', '<F3>', function() vim.lsp.buf.format() end, opts)
    vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', 'gl', function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end, opts)

    vim.api.nvim_set_hl(0, "LspInlayHint", {
      bg = "NONE",
      fg = "#999999",
      italic = true,
    })

    vim.keymap.set('n', '<leader>i', function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled(opts),
        opts
      )
    end, opts)
  end
})
