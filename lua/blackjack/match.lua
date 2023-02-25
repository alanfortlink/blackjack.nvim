local M = {}

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

local shuffle_deck = function()
  for i = 1, 52 do
    local temp = M.deck[i]
    local j = math.random(52)
    M.deck[i] = M.deck[j]
    M.deck[j] = temp
  end
end

M.player_picks_card = function()
  local card = pick_card(true)
  M.player_cards[#M.player_cards + 1] = card

  if M.get_player_total() > 21 then
    M.match_state = M.GAME_OVER
  end
end

M.dealer_picks_card = function()
  local card = pick_card(true)
  M.dealer_cards[#M.dealer_cards + 1] = card

  if M.get_dealer_total() >= 17 then
    M.match_state = M.GAME_OVER
  end
end

M.start_new_match = function()
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
