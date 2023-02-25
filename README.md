# Blackjack.nvim

Blackjack.nvim is a neovim plugin that implements a classic BlackJack game in neovim.

https://user-images.githubusercontent.com/3660978/221375547-a74f4f9f-b593-4e52-8b30-954757e30271.mov

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
