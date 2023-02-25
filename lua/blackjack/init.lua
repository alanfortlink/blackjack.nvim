local commands = require("blackjack.commands")

local M = {}

M.setup = function(opts)
  commands.create_commands()
end

return M
