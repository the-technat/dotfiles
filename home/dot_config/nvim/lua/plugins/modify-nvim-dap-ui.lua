return {
  "rcarriga/nvim-dap-ui",
  opts = {
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.75 },
          { id = "breakpoints", size = 0.25 },
        },
        position = "right",
        size = 40,
      },
      {
        elements = {
          { id = "repl", size = 1 },
        },
        position = "bottom",
        size = 20,
      },
    },
  },
}
