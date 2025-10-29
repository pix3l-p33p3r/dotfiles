local set = vim.api.nvim_set_keymap

-- Ensure <Esc> exits insert mode reliably
set("i", "<Esc>", "<Esc>", { noremap = true, silent = true })

-- Convenience chord to leave insert mode quickly
set("i", "jj", "<Esc>", { noremap = true, silent = true })
