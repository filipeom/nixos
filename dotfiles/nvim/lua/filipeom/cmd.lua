local autocmd = vim.api.nvim_create_autocmd

-- Restore cursor position on entering a buffer
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "gitcommit" then return end
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})

-- On entering a buffer restore last view
autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" and vim.bo.filetype ~= "gitcommit" then
      vim.cmd("silent! loadview")
    end
  end,
})

-- On leaving create the view
autocmd("BufWinLeave", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" and vim.bo.filetype ~= "gitcommit" then
      vim.cmd("silent! mkview")
    end
  end,
})

-- Remove whitespace before saving file
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Skip .eml files
    if vim.bo.filetype ~= "mail" then
      vim.cmd([[%s/\s\+$//e]])
    end
  end,
})

-- Invoke dune on 'ocaml' filetypes
autocmd("Filetype", {
  pattern = { "ocaml", "dune" },
  command = [[ setlocal makeprg=dune\ build\ @all ]]
})

-- Invoke cargo on 'rust' filetypes
autocmd("Filetype", {
  pattern = { "rust", "toml" },
  command = [[ setlocal makeprg=cargo\ build ]]
})
