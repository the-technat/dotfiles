return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			sources = {
				explorer = {
					hidden = true, -- show dotfiles (what H toggles)
					ignored = true, -- show gitignored files (what I toggles)
				},
			},
		},
	},
}
