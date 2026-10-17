-- remove LazyVim's floating-terminal toggles (<C-/> and its terminal alias <C-_>, i.e. Ctrl+-)
for _, mode in ipairs({ "n", "t" }) do
  for _, lhs in ipairs({ "<c-/>", "<c-_>" }) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

vim.keymap.set("n", "<leader>ob", function()
  vim.ui.open(vim.fn.expand("%:p"))
end, { desc = "Open file in browser" })
