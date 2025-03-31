# blink-cmp-tmux

Port of the [andersevenrud/cmp-tmux](https://github.com/andersevenrud/cmp-tmux)
completion source for the [blink.cmp] [Neovim](https://github.com/neovim/neovim)
plugin.

## Features

- Integrates with [tmux] to provide completion suggestions based on the content
  of [tmux] panes.
- Supports capturing content from all panes or only the current pane.
- Allows capturing the history of panes for more comprehensive suggestions.
- Configurable trigger characters to activate completions.

## Requirements

- [tmux]
- [blink.cmp]

## Installation & Configuration

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "saghen/blink.cmp",
  dependencies = {
      "mgalliou/blink-cmp-tmux",
  },
  opts = {
    sources = {
      default = {
        --- your other sources
        "tmux",
      },
      providers = {
        tmux = {
          module = "blink-cmp-tmux",
          name = "tmux",
          -- default options
          opts = {
            all_panes = false,
            capture_history = false,
            -- only suggest completions from `tmux` if the `trigger_chars` are
            -- used
            triggered_only = false,
            trigger_chars = { "." }
          },
        },
      }
    }
  }
}
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you
have any suggestions, bug reports, or feature requests.

## Credits

- [andersevenrud](https://github.com/andersevenrud): for the original completion
  source
- [moyiz/blink-emoji.nvim](https://github.com/moyiz/blink-emoji.nvim) and
  [MahanRahmati/blink-nerdfont.nvim](https://github.com/MahanRahmati/blink-nerdfont.nvim)
  for some code inspiration

[tmux]: https://github.com/tmux/tmux
[blink.cmp]: https://github.com/Saghen/blink.cmp
