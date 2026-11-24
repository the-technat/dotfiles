-- https://github.com/smart-splits-nvim/backend-tmux#neovim
local keys = {}
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  local function map(lhs, fn, desc)
    keys[#keys + 1] = {
      lhs,
      function()
        require("smart-splits")[fn .. dir]()
      end,
      desc = desc .. " " .. dir,
    }
  end
  map("<A-" .. key .. ">", "resize_", "Resize")
  map("<C-" .. key .. ">", "move_cursor_", "Move")
  map("<leader>m" .. key, "swap_buf_", "Swap")
end

return {
  "smart-splits-nvim/smart-splits.nvim",
  opts = {
    mux = { backend = "smart-splits-backend-tmux" },
    move = { at_edge = "split" },
  },
  dependencies = {
    { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
  },
  keys = keys,
}
