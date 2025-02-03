vim.g.mapleader = " "

-- Use left-right to exit insert mode
-- vim.keymap.set('i', '<left><right>', '<ESC>', { desc = "Exit insert mode with left&right arrow keys"})

-- clear search highlights
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- -- Move window focus
vim.keymap.set("n", "<C-left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-right>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-down>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-up>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Move window focus
-- vim.keymap.set("n", "<c-left>", ":wincmd h<CR>")
-- vim.keymap.set("n", "<c-right>", ":wincmd l<CR>")
-- vim.keymap.set("n", "<c-down>", ":wincmd j<CR>")
-- vim.keymap.set("n", "<c-up>", ":wincmd k<CR>")

-- Split navigation
--vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
--vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
--vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
--vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab navigation
-- vim.keymap.set("n", "<C-n>", ":tabnew<CR>", { desc = "Create new tab" })
-- vim.keymap.set("n", "<C-S-left>", ":tabprevious<CR>", { desc = "Move to previous tab" })
-- vim.keymap.set("n", "<C-S-right>", ":tabnext<CR>", { desc = "Move to next tab" })
-- vim.keymap.set("n", "<C-x>", ":tabclose<CR>", { desc = "Close tab" })

-- Buffer and Tab Navigation
-- vim.keymap.set("n", "<C-S-right>", ":bnext<CR>", { desc = "Move to next buffer" })
-- vim.keymap.set("n", "<C-S-left>", ":bprevious<CR>", { desc = "Move to previous buffer" })
-- vim.keymap.set("n", "<C-x>", ":bdelete<CR>", { desc = "Close current buffer" })

-- Comment
vim.keymap.set("n", "<C-/>", "gcc", { desc = "toggle comment", remap = true })
vim.keymap.set("v", "<C-/>", "gc", { desc = "toggle comment", remap = true })
