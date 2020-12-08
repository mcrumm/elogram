# LiveViewScreenshots

Capture screenshots from Phoenix LiveView tests

## Installation

The package can be installed
by adding `live_view_screenshots` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_view_screenshots,
       only: :test, git: "https://github.com/mcrumm/live_view_screenshots.git"}
  ]
end
```

## Capturing Screenshots

Start the screenshots server in `test/test_helper.exs`:

```diff
+ PhoenixLiveViewTestScreenshots.start()
ExUnit.start()
```

Then capture a screenshot from your LiveView:

```elixir
defmodule MyAppWeb.PageLiveTest do

```

## Test Setup

### Headless Chrome

Start a headless browser before running your tests:

**Github Actions**
```yaml
steps:
    - name: Start Google Chrome
      run: google-chrome --headless --disable-gpu --remote-debugging-port=9222 &
```

**MacOS**
```sh
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --headless --disable-gpu --remote-debugging-port=9222
```

By default screenshots will be saved to `tmp/screenshots`, so you may wish to update your `.gitignore` file to include the tmp directory:

```.gitignore
# Temporary files for e.g. tests
/tmp
```

