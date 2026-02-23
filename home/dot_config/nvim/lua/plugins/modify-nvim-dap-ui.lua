return {
  "rcarriga/nvim-dap-ui",
  keys = {
    {
      "<leader>dx",
      function()
        require("dapui").float_element("console", { position = "center" })
      end,
      desc = "Show debug console",
    },
  },
  opts = {
    layouts = {
      {
        elements = {
          { id = "scopes", size = 1 },
        },
        position = "bottom",
        size = 15,
      },
    },
  },
}
