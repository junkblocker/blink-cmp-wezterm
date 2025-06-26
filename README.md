# blink-cmp-tmux

Port of the [mgalliou/blink-cmp-tmux](https://github.com/mgalliou/blink-cmp-tmux)
completion source for the [blink.cmp] [Neovim](https://github.com/neovim/neovim)
plugin.

## Features

- Integrates with [WezTerm] to provide completion suggestions based on the content
  of [WezTerm] tabs and panes in the current WezTerm window.
  - Support for all windows/workspaces/panes is pending WezTerm implementation.
- Supports capturing content from all panes or only the current pane.
- Allows capturing the history of panes for more comprehensive suggestions.
- Configurable trigger characters to activate completions.

## Requirements

- [WezTerm]
- [blink.cmp]

## Installation & Configuration

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "saghen/blink.cmp",
  dependencies = {
      "junkblocker/blink-cmp-wezterm",
  },
  opts = {
    sources = {
      default = {
        --- your other sources
        "wezterm",
      },
      providers = {
        wezterm = {
          module = "blink-cmp-wezterm",
          name = "wezterm",
          -- default options
          opts = {
            all_panes = false,
            capture_history = false,
            -- only suggest completions from `wezterm` if the `trigger_chars` are
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

-  [mgalliou/blink-cmp-tmux](https://github.com/mgalliou/blink-cmp-tmux) for the original completion source

[WezTerm]: https://wezterm.org
[blink.cmp]: https://github.com/Saghen/blink.cmp
