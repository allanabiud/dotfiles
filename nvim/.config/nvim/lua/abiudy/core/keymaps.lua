local opts = { silent = true, noremap = true }

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- clear search highlights
vim.keymap.set("n", "<C-c", ":nohl<CR>", { desc = "Clear search highlights", silent = true })

-- Move window focus
vim.keymap.set("n", "<C-left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-right>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-down>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-up>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Comment
vim.keymap.set("n", "<C-/>", "gcc", { desc = "toggle comment", remap = true })
vim.keymap.set("v", "<C-/>", "gc", { desc = "toggle comment", remap = true })

-- Tabbing
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Move line up/down
vim.keymap.set("v", "<S-up>", ":m '<-2<CR>gv=gv", { desc = "Move line down in visual mode" })
vim.keymap.set("v", "<S-down>", ":m '>+1<CR>gv=gv", { desc = "Move line up in visual mode" })
