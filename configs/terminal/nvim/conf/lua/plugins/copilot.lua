-- GitHub Copilot for Neovim
-- https://github.com/github/copilot.vim

return {
	"github/copilot.vim",
	event = "VeryLazy",
	config = function()
		-- GitHub Copilot configuration
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_assume_mapped = true
		vim.g.copilot_tab_fallback = ""

		-- Key mappings for Copilot
		local keymap = vim.keymap.set
		local opts = { noremap = true, silent = true }

		-- Accept suggestion with Ctrl+Space
		keymap("i", "<C-Space>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Accept Copilot suggestion",
		})

		-- Accept word suggestion with Ctrl+Right
		keymap("i", "<C-Right>", 'copilot#Accept("\\<Right>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Accept Copilot word",
		})

		-- Dismiss suggestion with Ctrl+Escape
		keymap("i", "<C-Escape>", 'copilot#Dismiss()', {
			expr = true,
			replace_keycodes = false,
			desc = "Dismiss Copilot suggestion",
		})

		-- Next suggestion with Ctrl+]
		keymap("i", "<C-]>", 'copilot#Next()', {
			expr = true,
			replace_keycodes = false,
			desc = "Next Copilot suggestion",
		})

		-- Previous suggestion with Ctrl+[
		keymap("i", "<C-[>", 'copilot#Previous()', {
			expr = true,
			replace_keycodes = false,
			desc = "Previous Copilot suggestion",
		})

		-- Panel with Ctrl+Shift+P
		keymap("i", "<C-S-p>", "<cmd>Copilot panel<cr>", {
			desc = "Open Copilot panel",
		})

		-- Status with Ctrl+Shift+S
		keymap("i", "<C-S-s>", "<cmd>Copilot status<cr>", {
			desc = "Show Copilot status",
		})

		-- Enable/disable with Ctrl+Shift+E
		keymap("i", "<C-S-e>", "<cmd>Copilot enable<cr>", {
			desc = "Enable Copilot",
		})
		keymap("i", "<C-S-d>", "<cmd>Copilot disable<cr>", {
			desc = "Disable Copilot",
		})

		-- Normal mode mappings
		keymap("n", "<leader>cp", "<cmd>Copilot panel<cr>", {
			desc = "Open Copilot panel",
		})
		keymap("n", "<leader>cs", "<cmd>Copilot status<cr>", {
			desc = "Show Copilot status",
		})
		keymap("n", "<leader>ce", "<cmd>Copilot enable<cr>", {
			desc = "Enable Copilot",
		})
		keymap("n", "<leader>cd", "<cmd>Copilot disable<cr>", {
			desc = "Disable Copilot",
		})
	end,
}
