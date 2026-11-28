return {
	{
		"mfussenegger/nvim-jdtls",
		-- disable test feature, rely on neotest-java
		-- don't put metadata into my git workdir
		-- src: https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/3367
		opts = function(_, opts)
			opts.test = false
			table.insert(opts.cmd, "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false")
		end,
	},
	{
		-- add https://github.com/rcasia/neotest-java
		"nvim-neotest/neotest",
		dependencies = { "rcasia/neotest-java" },
		opts = { adapters = { ["neotest-java"] = {} } },
	},
}
