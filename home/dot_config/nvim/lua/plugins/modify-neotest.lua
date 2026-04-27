return {
  "nvim-neotest/neotest",
  keys = {
    {
      "<leader>tA",
      function()
        require("neotest").run.run({ suite = true })
      end,
      desc = "Run all tests (project)",
    },
  },
}
