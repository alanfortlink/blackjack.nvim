local popup = require("plenary.popup")
local utils = require("blackjack.utils")
local match = require("blackjack.match")

local M = {}

local bjack_buf_id = nil -- Current buf id
local bjack_win_id = nil -- Current win id

-- Not really used but nice to have what I've settled for
local DEALER_HEADER_HEIGHT = 1
local DEALER_CARDS_HEIGHT = 5
local PLAYER_HEADER_HEIGHT = 1
local PLAYER_CARDS_HEIGHT = 5
local ACTIONS_HEIGHT = 2
local CARD_WIDTH = 3
local MAX_CARDS = 12

local WIDTH = 2 * CARD_WIDTH * MAX_CARDS
local HEIGHT = DEALER_HEADER_HEIGHT
    + DEALER_CARDS_HEIGHT
    + PLAYER_HEADER_HEIGHT
    + PLAYER_CARDS_HEIGHT
    + ACTIONS_HEIGHT
    + 3

local DEFAULT_BORDER_CHARS = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

M.open_game = function()
  if bjack_buf_id ~= nil then
    M.destroy()
  end

  -- Create a new buffer if we don't have one
  if bjack_buf_id == nil then
    bjack_buf_id = vim.api.nvim_create_buf(false, false)
  end

  if bjack_win_id == nil then
    bjack_win_id, _ = popup.create(bjack_buf_id, {
      title = "Black Jack (q)",
      highlight = "BlackJackWindow",
      line = math.floor((vim.o.lines - HEIGHT) / 2),
      col = math.floor((vim.o.columns - WIDTH) / 2),
      minwidth = WIDTH,
      minheight = HEIGHT,
      borderchars = DEFAULT_BORDER_CHARS
    })
  end

  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "j", ":BlackJackOption1<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "k", ":BlackJackOption2<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "q", ":BlackJackQuit<CR>", { silent = true })

  M.render()
end

M.destroy = function()
  if bjack_win_id ~= nil then
    vim.api.nvim_win_close(bjack_win_id, true)
    bjack_win_id = nil
  end

  if bjack_buf_id ~= nil then
    vim.api.nvim_buf_delete(bjack_buf_id, { force = true })
    bjack_buf_id = nil
  end

end

local render_cards = function(lines, cards, is_turn, turn_message)
  local B = DEFAULT_BORDER_CHARS
  local start_line = #lines + 1

  -- Create empty lines to fill with cards
  for _ = 1, PLAYER_CARDS_HEIGHT do
    lines[#lines + 1] = ""
  end

  for _, card in ipairs(cards) do
    local symbol = card.symbol
    if not card.revealed then symbol = '?' end

    local extra = " "
    if symbol == '10' then extra = "" end

    lines[start_line] = lines[start_line] .. B[5] .. string.rep(B[1], CARD_WIDTH) .. B[6] .. " "
    lines[start_line + 1] = lines[start_line + 1] .. B[2] .. " " .. extra .. symbol .. B[4] .. " "
    -- lines[start_line + 2] = lines[start_line + 2] .. B[2] .. "       " .. B[4] .. " "
    lines[start_line + 2] = lines[start_line + 2] .. B[2] .. " " .. utils.get_suit(card) .. " " .. B[4] .. " "
    -- lines[start_line + 4] = lines[start_line + 4] .. B[2] .. "       " .. B[4] .. " "
    lines[start_line + 3] = lines[start_line + 3] .. B[2] .. symbol .. extra .. " " .. B[4] .. " "
    lines[start_line + 4] = lines[start_line + 4] .. B[8] .. string.rep(B[1], CARD_WIDTH) .. B[7] .. " "
  end

  if is_turn then
    lines[start_line + 2] = lines[start_line + 2] .. turn_message
  end
end

M.render = function()
  if bjack_buf_id == nil then
    return
  end

  local lines = {}
  local dealer_total = match.get_dealer_total()
  local player_total = match.get_player_total()

  local is_player_turn = match.match_state == match.PLAYER_PICKING_CARD
  local is_dealer_turn = match.match_state == match.DEALER_PICKING_CARD

  lines[#lines + 1] = "Dealer Cards ( " .. dealer_total .. " )"

  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], WIDTH)

  render_cards(lines, match.dealer_cards, is_dealer_turn, " Press <j> to reveal a new card")

  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], WIDTH)
  lines[#lines + 1] = "Player Cards ( " .. player_total .. " )"
  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], WIDTH)

  render_cards(lines, match.player_cards, is_player_turn, " Press <j> for a new card")

  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], WIDTH)
  local option1 = nil
  local option2 = nil
  local status = nil

  if match.match_state == match.GAME_OVER then
    option1 = "(j) Play Again"
    option2 = "(k) Quit"

    -- Set status
    if player_total > 21 then
      status = "YOU LOST!"
    elseif dealer_total > 21 then
      status = "YOU WON!"
    elseif player_total == dealer_total then
      status = "DRAW!"
    elseif player_total > dealer_total then
      status = "YOU WON!"
    else
      status = "YOU LOST!"
    end

  end

  if match.match_state == match.PLAYER_PICKING_CARD then
    option1 = "(j) Ask for card"
    option2 = "(k) End Turn"
    status = "Your Turn"
  end

  if match.match_state == match.DEALER_PICKING_CARD then
    option1 = "(j) Reveal card"
    option2 = "(k) Quit"
    status = "Dealer Turn"
  end

  local empty_space = WIDTH - string.len(option1) - string.len(option2)
  empty_space = empty_space - 4

  local remaining_space = empty_space - string.len(status)
  local empty = string.rep(" ", remaining_space / 2)

  local cmd = option1 .. " |" .. empty .. status .. empty .. "| " .. option2

  lines[#lines + 1] = cmd

  vim.api.nvim_buf_set_lines(bjack_buf_id, 0, -1, true, lines)
end

return M
