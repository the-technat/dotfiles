-- https://github.com/smart-splits-nvim/backend-tmux#neovim
return {
  "smart-splits-nvim/smart-splits.nvim",
  opts = {
    mux = { backend = "smart-splits-backend-tmux" },
    move = { at_edge = "split" },
  },
  dependencies = {
    { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
  },
  keys = {
    -- Resize splits
    {
      "<A-h>",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "Resize left",
    },
    {
      "<A-j>",
      function()
        require("smart-splits").resize_down()
      end,
      desc = "Resize down",
    },
    {
      "<A-k>",
      function()
        require("smart-splits").resize_up()
      end,
      desc = "Resize up",
    },
    {
      "<A-l>",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "Resize right",
    },
    -- Move between splits
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Move left",
    },
    {
      "<C-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "Move down",
    },
    {
      "<C-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "Move up",
    },
    {
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "Move right",
    },
    -- Swap buffers
    {
      "<leader><leader>h",
      function()
        require("smart-splits").swap_buf_left()
      end,
      desc = "Swap left",
    },
    {
      "<leader><leader>j",
      function()
        require("smart-splits").swap_buf_down()
      end,
      desc = "Swap down",
    },
    {
      "<leader><leader>k",
      function()
        require("smart-splits").swap_buf_up()
      end,
      desc = "Swap up",
    },
    {
      "<leader><leader>l",
      function()
        require("smart-splits").swap_buf_right()
      end,
      desc = "Swap right",
    },
  },
}
