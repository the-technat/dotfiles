return {
  "nvim-neotest/neotest",
  dependencies = { "rcasia/neotest-java" },
  opts = { adapters = { ["neotest-java"] = {} } },
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
