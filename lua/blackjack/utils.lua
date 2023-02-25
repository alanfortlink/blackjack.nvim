local match = require("blackjack.match")

local M = {}

M.get_suit = function(card)
  local suit_map = {
    [match.CLUBS] = '♣',
    [match.HEARTS] = '♥',
    [match.DIAMONDS] = '♦',
    [match.SPADES] = '♠',
  }

  if not card.revealed then
    return '?'
  end

  return suit_map[card.suit]
end

return M
