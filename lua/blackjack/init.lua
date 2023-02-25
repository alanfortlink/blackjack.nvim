local window = require("blackjack.window")

local M = {}

M.setup = function(opts)
  if opts.card_style ~= nil then
    window.card_style = opts.card_style
  end
end

return M
