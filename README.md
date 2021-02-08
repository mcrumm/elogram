# ELogram

<!-- MDOC -->
Capture screenshots with the [`Phoenix.LiveViewTest`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html) Element API.

**This package is EXPERIMENTAL and should not be used by anyone.**

## Installation

The package can be installed
by adding `elogram` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elogram,
       only: :test, git: "https://github.com/mcrumm/elogram.git"}
  ]
end
```

## Capturing Screenshots

Start the screenshots server in `test/test_helper.exs`:

```diff
+ Elogram.start()
ExUnit.start()
```

Then capture a screenshot from your LiveView:

```elixir
defmodule MyAppWeb.PageLiveTest do
  use MyAppWeb, :live_view
  import Elogram.CaptureScreenshot

  test "a thousand words", %{conn: conn} end
    {:ok, view, _} = live(conn, "/")

    assert view
      |> capture_screenshot("welcome.png")
      |> render() =~ "Welcome to Phoenix!"
  end
end
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

### Save Path

By default screenshots will be saved to `tmp/screenshots`, so you may wish to update your `.gitignore` file to include the tmp directory:

```.gitignore
# Temporary files for e.g. tests
/tmp
```

<!-- MDOC -->
