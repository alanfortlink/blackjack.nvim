# Blackjack.nvim

Blackjack.nvim is a neovim plugin that implements a classic BlackJack game in neovim.

## Requirements

- [Neovim](https://github.com/neovim/neovim) >= 0.5.0

## Installation

### Using [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'alanfortlink/blackjack.nvim',
  requires = {'nvim-lua/plenary.nvim'},
  config = function()
    require("blackjack").setup({})
  end
}
```

## Usage

To start a new game:
```vim
:BlackJackNewGame
```

To quit the game you can press `q` or:
```vim
BlackJackQuit
```

Press `j` and `k` to play the game and `q` to quit.
