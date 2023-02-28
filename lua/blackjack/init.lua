local window = require("blackjack.window")
local utils = require("blackjack.utils")
local match = require("blackjack.match")

local M = {}

M.setup = function(opts)
  opts = opts or {}

  if opts.card_style ~= nil then
    window.card_style = opts.card_style
  end

  if opts.scores_path ~= nil then
    match.scores_path = opts.scores_path
  end

  if opts.suit_style ~= nil then
    utils.suit_style = opts.suit_style
  end
end

return M
