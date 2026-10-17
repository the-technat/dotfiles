-- lua/plugins/java.lua
return {
  {
    -- done by neotest-java instead (see modify-neotest), two plugins responsible for testing get's confusing and I prefer neotest
    "mfussenegger/nvim-jdtls",
    opts = {
      test = false,
      jdtls = {
        settings = {
          java = {
            import = { generatesMetadataFilesAtProjectRoot = false },
          },
        },
      },
    },
  },
}
