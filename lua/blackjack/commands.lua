local utils = require("blackjack.utils")
local match = require("blackjack.match")
local window = require("blackjack.window")

local M = {}

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

local player_end_turn = function()
  match.match_state = match.DEALER_PICKING_CARD
end

local dealer_next_card = function()
  if match.match_state ~= match.DEALER_PICKING_CARD then
    return
  end

  if not match.dealer_cards[2].revealed then
    match.dealer_cards[2].revealed = true
    return
  end

  match.dealer_picks_card()
end

local dealer_end_turn = function()
  end_game()
end

local option1 = function()
  if match.match_state == match.PLAYER_PICKING_CARD then
    player_next_card()
  elseif match.match_state == match.DEALER_PICKING_CARD then
    dealer_next_card()
  else -- GAME_OVER
    new_game()
  end

  window.render()
end

local option2 = function()
  if match.match_state == match.PLAYER_PICKING_CARD then
    player_end_turn()
  elseif match.match_state == match.DEALER_PICKING_CARD then
    dealer_end_turn()
  else -- GAME_OVER
    end_game()
  end

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
  vim.api.nvim_create_user_command("BlackJackDealerNextCard", dealer_next_card, {})
  vim.api.nvim_create_user_command("BlackJackDealerEndGame", dealer_end_turn, {})

  -- Options
  vim.api.nvim_create_user_command("BlackJackOption1", option1, {})
  vim.api.nvim_create_user_command("BlackJackOption2", option2, {})
end

return M
