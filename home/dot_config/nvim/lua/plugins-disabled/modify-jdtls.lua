return {
  {
    "mfussenegger/nvim-jdtls",
    -- don't put metadata into my git workdir
    -- disable test feature, rely on neotest-java
    -- src: https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/3367
    opts = function(_, opts)
      opts.test = false
      table.insert(opts.cmd, "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false")
    end,
  },
}
