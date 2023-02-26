# Blackjack.nvim

Blackjack.nvim is a neovim plugin that implements a classic BlackJack game in neovim.

Using the "mini" style of cards:


https://user-images.githubusercontent.com/3660978/221380892-8107e62d-b3d1-49a5-b4c7-9e09e6c632f6.mov




Using the "large" style of cards:



https://user-images.githubusercontent.com/3660978/221390688-2c53d1e3-74b5-4f00-8f30-30a9388621d1.mov



---

## Requirements

- [Neovim](https://github.com/neovim/neovim) >= 0.5.0

## Installation

### Using [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'alanfortlink/blackjack.nvim',
  requires = {'nvim-lua/plenary.nvim'},
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug 'nvim-lua/plenary.nvim'
Plug 'alanfortlink/blackjack.nvim'
```

### Setup

```lua
require("blackjack").setup({
  card_style = "mini", -- Can be "mini" or "large"
  suit_style = "black", -- Can be "black" or "white"
})
```

## Usage

To start a new game:
```vim
:BlackJackNewGame
```

To quit the game you can press `q` or:
```vim
:BlackJackQuit
```

To reset the scores:
```vim
:BlackJackResetScores
```

Press `j` and `k` to play the game and `q` to quit.
