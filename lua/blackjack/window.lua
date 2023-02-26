local popup = require("plenary.popup")

local utils = require("blackjack.utils")
local match = require("blackjack.match")

local M = {
  card_style = "mini",
  -- large
}

local bjack_buf_id = nil -- Current buf id
local bjack_win_id = nil -- Current win id

-- Not really used but nice to have what I've settled for
local DEALER_HEADER_HEIGHT = 1
local PLAYER_HEADER_HEIGHT = 1
local ACTIONS_HEIGHT = 2
local get_card_width = function()
  if M.card_style == "large" then
    return 5
  end

  return 3
end

local MAX_CARDS = 10

local get_width = function()
  return math.max(50, (get_card_width() * (MAX_CARDS + 1)))
end

local get_card_height = function()
  if M.card_style == "large" then
    return 7
  end

  return 5
end

local get_height = function() return DEALER_HEADER_HEIGHT
      + get_card_height()
      + PLAYER_HEADER_HEIGHT
      + get_card_height()
      + ACTIONS_HEIGHT
      + 3
end

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
      title = "Black Jack (W: " ..
          match.scores.player_score .. " - L: " .. match.scores.dealer_score .. ")   <q> to quit",
      highlight = "BlackJackWindow",
      line = math.floor((vim.o.lines - get_height()) / 2),
      col = math.floor((vim.o.columns - get_width()) / 2),
      minwidth = get_width(),
      minheight = get_height(),
      borderchars = DEFAULT_BORDER_CHARS
    })
  end

  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "j", ":BlackJackOption1<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "k", ":BlackJackOption2<CR>", { silent = true })
  vim.api.nvim_buf_set_keymap(bjack_buf_id, "n", "q", ":BlackJackQuit<CR>", { silent = true })

  M.render()
end

M.update_title = function()
  if bjack_buf_id == nil then
    return
  end

  M.destroy()
  M.open_game()
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

local render_cards = function(lines, cards, is_turn, option1_message, option2_message)
  local B = DEFAULT_BORDER_CHARS
  local start_line = #lines + 1

  -- Create empty lines to fill with cards
  for _ = 1, get_card_height() do
    lines[#lines + 1] = ""
  end

  for _, card in ipairs(cards) do
    local symbol = card.symbol
    if not card.revealed then symbol = '?' end

    local extra = " "
    if symbol == '10' then extra = "" end

    lines[start_line] = lines[start_line] .. string.format("%s%s%s ", B[5], string.rep(B[1], get_card_width()), B[6])

    if M.card_style == "large" then
      -- ╭─────╮ start_line
      -- │    4│ start_line+1
      -- │     │ start_line+2
      -- │  ♤  │ start_line+3
      -- │     │ start_line+4
      -- │4    │ start_line+5
      -- ╰─────╯ start_line+6

      lines[start_line + 1] = lines[start_line + 1] .. string.format("%s   %s%s%s ", B[2], extra, symbol, B[4])
      lines[start_line + 2] = lines[start_line + 2] .. string.format("%s     %s ", B[2], B[4])
      lines[start_line + 3] = lines[start_line + 3] .. string.format("%s  %s  %s ", B[2], utils.get_suit(card), B[4])
      lines[start_line + 4] = lines[start_line + 4] .. string.format("%s     %s ", B[2], B[4])
      lines[start_line + 5] = lines[start_line + 5] .. string.format("%s%s%s   %s ", B[2], symbol, extra, B[4])
      lines[start_line + 6] = lines[start_line + 6] ..
          string.format("%s%s%s ", B[8], string.rep(B[1], get_card_width()), B[7])
    else
      -- ╭───╮ start_line
      -- │  A│ start_line+1
      -- │ ♤ │ start_line+2
      -- │A  │ start_line+3
      -- ╰───╯ start_line+4

      lines[start_line + 1] = lines[start_line + 1] .. string.format("%s %s%s%s ", B[2], extra, symbol, B[4])
      lines[start_line + 2] = lines[start_line + 2] .. string.format("%s %s %s ", B[2], utils.get_suit(card), B[4])
      lines[start_line + 3] = lines[start_line + 3] .. string.format("%s%s%s %s ", B[2], symbol, extra, B[4])
      lines[start_line + 4] = lines[start_line + 4] ..
          string.format("%s%s%s ", B[8], string.rep(B[1], get_card_width()), B[7])
    end
  end

  if is_turn then
    lines[start_line + 2] = lines[start_line + 2] .. option1_message
    lines[start_line + 3] = lines[start_line + 3] .. option2_message
  end
end

local get_highlight = function(score)
  if score < 11 then
    return "MoreMsg"
  end

  if score < 17 then
    return "WarningMsg"
  end

  return "ErrorMsg"
end

local get_player_highlight = function()
  return get_highlight(match.get_player_total())
end

local get_dealer_highlight = function()
  return get_highlight(match.get_dealer_total())
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

  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], get_width())

  render_cards(lines, match.dealer_cards, is_dealer_turn, " Press <j> to reveal a new card", "")

  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], get_width())
  lines[#lines + 1] = "Player Cards ( " .. player_total .. " )"
  lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], get_width())

  render_cards(lines, match.player_cards, is_player_turn, " Press <j> for a new card", " Press <k> to end your turn")

  local option1 = nil
  local option2 = nil
  local status = nil

  local highlight = "MoreMsg"
  if match.match_state == match.GAME_OVER then
    option1 = "(j) Play Again"
    option2 = "(k) Quit"

    -- Set status
    if player_total > 21 then
      status = "YOU LOST!"
      highlight = "ErrorMsg"
    elseif dealer_total > 21 then
      status = "YOU WON!"
      highlight = "MoreMsg"
    elseif player_total == dealer_total then
      status = "DRAW!"
      highlight = "WarningMsg"
    elseif player_total > dealer_total then
      status = "YOU WON!"
      highlight = "MoreMsg"
    else
      status = "YOU LOST!"
      highlight = "ErrorMsg"
    end

  end

  if match.match_state == match.PLAYER_PICKING_CARD then
    option1 = ""
    option2 = ""
    status = ""
  end

  if match.match_state == match.DEALER_PICKING_CARD then
    option1 = ""
    option2 = ""
    status = ""
  end

  local empty_space = get_width() - string.len(option1) - string.len(option2)
  empty_space = empty_space - 4

  local remaining_space = empty_space - string.len(status)
  local empty = string.rep(" ", remaining_space / 2)

  local cmd = option1 ..
      " " .. DEFAULT_BORDER_CHARS[2] .. empty .. status .. empty .. DEFAULT_BORDER_CHARS[2] .. " " .. option2

  if option1 ~= "" or option2 ~= "" or status ~= "" then
    lines[#lines + 1] = string.rep(DEFAULT_BORDER_CHARS[1], get_width())
    lines[#lines + 1] = cmd
  end

  vim.api.nvim_buf_set_lines(bjack_buf_id, 0, -1, true, lines)

  if status ~= "" then
    local col_start = string.len(option1) + 4
    local col_end = col_start + string.len(status) + remaining_space
    vim.api.nvim_buf_add_highlight(bjack_buf_id, 0, highlight, #lines - 1, col_start, col_end)
  end

  vim.api.nvim_buf_add_highlight(bjack_buf_id, 0, get_dealer_highlight(), 0, 15, 17)

  local player_line = 8

  if M.card_style == "large" then
    player_line = 10
  end

  vim.api.nvim_buf_add_highlight(bjack_buf_id, 0, get_player_highlight(), player_line, 15, 17)
end

return M
