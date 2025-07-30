-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- In tmux, esc happens to trigger alt if not waiting long enough. I don't use these keybinds anyways.
-- See: https://github.com/LunarVim/LunarVim/issues/1857#issuecomment-2273066106
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")
