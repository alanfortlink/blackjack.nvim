local match = require("blackjack.match")
local window = require("blackjack.window")

local M = {}
local autoplay_delay = 1500 -- 2 seconds between cards

local autoplay = nil

local new_game = function()
  match.start_new_match()
  window.open_game()
end

local end_game = function()
  window.destroy()
end

local player_next_card = function()
  if match.match_state ~= match.PLAYER_PICKING_CARD then
    return
  end
  match.player_picks_card()
end

local dealer_next_card = function()
  if match.match_state ~= match.DEALER_PICKING_CARD then
    return
  end

  match.dealer_picks_card() -- updates the match_state if game is over

  if match.match_state ~= match.GAME_OVER then
    autoplay()
  end
end

local player_end_turn = function()
  if match.match_state ~= match.PLAYER_PICKING_CARD then
    return
  end
  match.match_state = match.DEALER_PICKING_CARD
  autoplay()
end

local dealer_end_turn = function()
  end_game()
end

autoplay = function()
  vim.defer_fn(function()
    dealer_next_card()
    window.render()
  end, autoplay_delay)
end

local option1 = function()
  if match.match_state == match.PLAYER_PICKING_CARD then
    player_next_card()
  elseif match.match_state == match.DEALER_PICKING_CARD then
    -- dealer_next_card()
  else -- GAME_OVER
    new_game()
  end

  window.render()
end

local option2 = function()
  if match.match_state == match.PLAYER_PICKING_CARD then
    player_end_turn()
  elseif match.match_state == match.DEALER_PICKING_CARD then
    -- dealer_end_turn()
  else -- GAME_OVER
    end_game()
  end

  window.render()
end

local reset_scores = function()
  match.reset_scores()
  window.update_title()
  window.render()
end

M.create_commands = function()
  -- Black Jack
  vim.api.nvim_create_user_command("BlackJackNewGame", new_game, {})
  vim.api.nvim_create_user_command("BlackJackQuit", end_game, {})

  -- Player Gameplay
  vim.api.nvim_create_user_command("BlackJackPlayerNextCard", player_next_card, {})
  vim.api.nvim_create_user_command("BlackJackPlayerEndTurn", player_end_turn, {})

  -- Dealer Gameplay
  -- vim.api.nvim_create_user_command("BlackJackDealerNextCard", dealer_next_card, {})
  vim.api.nvim_create_user_command("BlackJackDealerEndGame", dealer_end_turn, {})

  -- Options
  vim.api.nvim_create_user_command("BlackJackOption1", option1, {})
  vim.api.nvim_create_user_command("BlackJackOption2", option2, {})

  vim.api.nvim_create_user_command("BlackJackResetScores", reset_scores, {})
end

return M
