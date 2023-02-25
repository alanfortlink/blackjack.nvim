local match = require("blackjack.match")

local end_game = function(win_id, buf_id)
  vim.api.nvim_win_close(win_id, true)
  vim.api.nvim_buf_delete(buf_id, { force = true })
end

local update_buf_content = function(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, true, match.player_cards)
end

local M = {}

M.create_commands = function(buf_id, win_id)
  vim.api.nvim_buf_create_user_command(buf_id, "BlackJackEndGame", function()
    end_game(win_id, buf_id)
  end, {})

  vim.api.nvim_buf_create_user_command(buf_id, "BlackJackAnotherCard", function()
    match.player_cards[#match.player_cards + 1] = "card"
    update_buf_content(buf_id)
  end, {})

end

return M
