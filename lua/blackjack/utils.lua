local match = require("blackjack.match")

local M = {}

M.keybindings = {
  ["next"] = "j",
  ["finish"] = "k",
  ["quit"] = "q",
}

M.suit_style = "black"
-- "white"

M.get_suit = function(card)
  local suit_map = {
    [match.CLUBS] = '♣',
    [match.HEARTS] = '♥',
    [match.DIAMONDS] = '♦',
    [match.SPADES] = '♠',
  }

  if M.suit_style == "white" then
    suit_map = {
      [match.CLUBS] = '♧',
      [match.HEARTS] = '♡',
      [match.DIAMONDS] = '♢',
      [match.SPADES] = '♤',
    }
  end

  if not card.revealed then
    return '?'
  end

  return suit_map[card.suit]
end

M.apply_keybindings = function(kb)
  for key, value in pairs(kb) do
    M.keybindings[key] = value
  end
end

return M
