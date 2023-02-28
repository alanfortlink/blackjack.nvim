local path = require("plenary.path")
local data_path = vim.fn.stdpath("data")
local default_scores_path = string.format("%s/blackjackscores.json", data_path);

local M = {}

M.scores_path = nil

local get_scores_path = function()
  if M.scores_path == nil then
    return default_scores_path
  end

  return M.scores_path
end

-- To keep track of who's winning
M.scores = {
  player_score = 0,
  dealer_score = 0,
}

M.deck = {} -- Cards in the deck
M.dealer_cards = {} -- Cards with the dealer
M.player_cards = {} -- Cards with the player

-- Game possible states
M.PLAYER_PICKING_CARD = 0
M.DEALER_PICKING_CARD = 1
M.GAME_OVER = 2

-- Game current state
M.match_state = M.PLAYER_PICKING_CARD

-- Card suits
M.CLUBS = 0
M.DIAMONDS = 1
M.HEARTS = 2
M.SPADES = 3

local pick_card = function(reveal)
  -- Removes and returns a card from the top of the deck.
  -- reveal = `true` if we should update 'revealed'.
  local card = M.deck[#M.deck]
  M.deck[#M.deck] = nil

  if reveal then
    card.revealed = true
  end

  return card
end

local deal_initial_hands = function()
  -- Dealer's first card is revealed
  M.dealer_cards[#M.dealer_cards + 1] = pick_card(true)

  -- Dealer's second card is NOT revealed yet
  M.dealer_cards[#M.dealer_cards + 1] = pick_card(false)

  -- Player's first card is revealed
  M.player_cards[#M.player_cards + 1] = pick_card(true)
end

local save_scores = function()
  path:new(get_scores_path()):write(vim.fn.json_encode(M.scores), "w")
end

local read_scores_ = function()
  return vim.json.decode(path:new(get_scores_path()):read())
end

local read_scores = function()
  local ok, scores = pcall(read_scores_)

  if not ok then
    scores = M.scores
  end

  M.scores = scores
end

local update_scores = function()
  if M.match_state ~= M.GAME_OVER then
    return
  end

  local player_total = M.get_player_total()
  local dealer_total = M.get_dealer_total()

  -- Set status
  if player_total > 21 then
    M.scores.dealer_score = M.scores.dealer_score + 1
  elseif dealer_total > 21 then
    M.scores.player_score = M.scores.player_score + 1
  elseif player_total > dealer_total then
    M.scores.player_score = M.scores.player_score + 1
  elseif player_total < dealer_total then
    M.scores.dealer_score = M.scores.dealer_score + 1
  end

  save_scores()
end

local shuffle_deck = function()
  math.randomseed(os.clock())
  for i = 1, 52 do
    local temp = M.deck[i]
    local j = math.random(52)
    M.deck[i] = M.deck[j]
    M.deck[j] = temp
  end
end

M.reset_scores = function()
  M.scores.dealer_score = 0
  M.scores.player_score = 0

  save_scores()
end

M.player_picks_card = function()
  local card = pick_card(true)
  M.player_cards[#M.player_cards + 1] = card

  if M.get_player_total() > 21 then
    M.match_state = M.GAME_OVER
  end

  update_scores()
end

M.dealer_picks_card = function()
  if not M.dealer_cards[2].revealed then
    M.dealer_cards[2].revealed = true
  else
    local card = pick_card(true)
    M.dealer_cards[#M.dealer_cards + 1] = card
  end

  if M.get_dealer_total() >= 17 then
    M.match_state = M.GAME_OVER
  end

  update_scores()
end

M.start_new_match = function()
  read_scores()

  M.match_state = M.PLAYER_PICKING_CARD

  M.deck = {}
  M.dealer_cards = {}
  M.player_cards = {}

  -- Create new deck of cards (like a real casino!!)
  for suit = 0, 3 do
    for value = 2, 14 do
      local symbol = tostring(value)
      if value == 11 then
        value = 10
        symbol = 'J'
      end

      if value == 12 then
        value = 10
        symbol = 'Q'
      end

      if value == 13 then
        value = 10
        symbol = 'K'
      end

      if value == 14 then
        symbol = 'A'
        value = 11
      end

      M.deck[#M.deck + 1] = {
        suit = suit,
        symbol = symbol,
        value = value,
        revealed = false,
      }
    end
  end

  shuffle_deck()
  deal_initial_hands()
end

local get_total = function(cards)
  local total = 0
  for _, card in ipairs(cards) do
    if card.revealed then
      total = total + card.value
    end
  end

  if total > 21 then
    for _, card in ipairs(cards) do
      if card.revealed and card.symbol == 'A' then
        total = total - 10
        if total <= 21 then
          break
        end
      end
    end
  end

  return total
end

M.get_player_total = function()
  return get_total(M.player_cards)
end

M.get_dealer_total = function()
  return get_total(M.dealer_cards)
end

return M
