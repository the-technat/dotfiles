-- move macro recording to capital Q to avoid triggering it accidentially
vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "q", { desc = "Record macro" })
