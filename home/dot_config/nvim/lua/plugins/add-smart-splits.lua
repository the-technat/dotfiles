-- https://github.com/smart-splits-nvim/backend-tmux#neovim
return {
  "smart-splits-nvim/smart-splits.nvim",
  opts = {
    mux = { backend = "smart-splits-backend-tmux" },
    move = { at_edge = "stop" },
  },
  dependencies = {
    { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
  },
  keys = {
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

    {
      "<leader>mh",
      function()
        require("smart-splits").swap_buf_left()
      end,
      desc = "Swap left",
    },
    {
      "<leader>mj",
      function()
        require("smart-splits").swap_buf_down()
      end,
      desc = "Swap down",
    },
    {
      "<leader>mk",
      function()
        require("smart-splits").swap_buf_up()
      end,
      desc = "Swap up",
    },
    {
      "<leader>ml",
      function()
        require("smart-splits").swap_buf_right()
      end,
      desc = "Swap right",
    },
  },
}
