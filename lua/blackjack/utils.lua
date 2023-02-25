local commands = require("blackjack.commands")
local popup = require("plenary.popup")

local M = {}

M.get_game_window = function()
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local width = 30
  local height = 20

  local bjack_buf_id = vim.api.nvim_create_buf(false, false)

  local bjack_win_id, win = popup.create(bjack_buf_id, {
    title = "Black Jack (q)",
    highlight = "BlackJackWindow",
    line = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars
  })

  commands.create_commands(bjack_buf_id, bjack_win_id)

  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "q", ":BlackJackEndGame<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "j", ":BlackJackAnotherCard<CR>", { silent = true })

  return bjack_buf_id, bjack_win_id
end

return M
