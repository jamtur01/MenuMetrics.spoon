# MenuMetrics.spoon

`MenuMetrics` is a Hammerspoon spoon designed to display system metrics (CPU, memory, disk usage) directly in your macOS menu bar, rotating through the different metrics at a user-defined interval.

## Features

- Displays system memory usage, disk usage, and CPU usage in the macOS menu bar.
- Rotates between different metrics every few seconds.
- Lightweight and customizable.

## Installation

1. Download the Spoon:

   - [MenuMetrics.spoon.zip](https://github.com/username/MenuMetrics.spoon/raw/master/MenuMetrics.spoon.zip)

2. Move the downloaded `.spoon` directory to `~/.hammerspoon/Spoons/`:

```bash
mv MenuMetrics.spoon ~/.hammerspoon/Spoons/
```

Add the following to your `init.lua` in Hammerspoon:

```lua
hs.loadSpoon("MenuMetrics")
spoon.MenuMetrics:start()
```

## Usage

Once installed and started, MenuMetrics will begin rotating through system metrics in the menu bar. Each metric will be displayed with an accompanying icon and usage percentage. By default, the menu updates every 5 seconds, cycling between:

- 🧠 Memory usage
- 📀 Disk usage
- ⚙️ CPU usage

## Customization

### Change update interval: Modify the updateInterval to adjust how often the metrics update (default is 5 seconds):

```lua
spoon.MenuMetrics.updateInterval = 10 -- Update every 10 seconds
```

### Manually control the rotation:

Use the :updateMenu() function to manually force an update:

```lua
spoon.MenuMetrics:updateMenu()
```

## Requirements

- Hammerspoon (latest version)
- macOS (tested on Monterey and later)

## License

MenuMetrics is licensed under the MIT License.

## Author

Created by James Turnbull.
