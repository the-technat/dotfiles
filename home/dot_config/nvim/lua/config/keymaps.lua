-- remove LazyVim's floating-terminal toggles (<C-/> and its terminal alias <C-_>, i.e. Ctrl+-)
-- use smarts-split and tmux panes instead (way better terminal handling, just as fast)
for _, mode in ipairs({ "n", "t" }) do
  for _, lhs in ipairs({ "<c-/>", "<c-_>" }) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

-- quick shortcut to open current file in OS default app
-- useful for HTML pages and similar that you want to see in the browser
vim.keymap.set("n", "<leader>ob", function()
  vim.ui.open(vim.fn.expand("%:p"))
end, { desc = "Open file in browser" })

-- move macro recording to capital Q to avoid triggering it accidentially
vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "q", { desc = "Record macro" })

-- disable the status line for presenting
local saved_laststatus = 3 -- LazyVim's default (one global statusline)

Snacks.toggle({
  name = "Statusline",
  get = function()
    return vim.o.laststatus ~= 0
  end,
  set = function(enabled)
    if enabled then
      vim.o.laststatus = saved_laststatus
    else
      saved_laststatus = vim.o.laststatus
      vim.o.laststatus = 0
    end
  end,
}):map("<leader>uS")
