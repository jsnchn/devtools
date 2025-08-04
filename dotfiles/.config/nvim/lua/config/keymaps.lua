-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if os.getenv("TMUX") then
  vim.g.tmux_navigator_no_mappings = 1
  vim.g.tmux_navigator_save_on_switch = 2

  vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { silent = true })
  vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { silent = true })
  vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { silent = true })
  vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { silent = true })
  vim.keymap.set("n", "<C-\\>", ":TmuxNavigatePrevious<CR>", { silent = true })
end
