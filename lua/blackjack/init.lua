local utils = require("blackjack.utils")

local M = {}

M.new_game = function()
  buf_id, win_id = utils.get_game_window()
end

M.reload = function()
  package.loaded["blackjack"] = nil
  require("blackjack")
end

return M
