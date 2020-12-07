defmodule PhoenixLiveViewTest.CaptureScreenshot do
  @moduledoc """
  Functionality to capture LiveView screenshots for testing.
  """
  alias PhoenixLiveViewTestScreenshots.Browser

  @doc """
  Captures a screenshot of a LiveView under test.

  ## Options

    * `:namespace` - Optional. The screenshot namespace.
      Defaults to `PhoenixLiveViewTestScreenshots`.

  ## Examples

      test "one thousand words" end
        {:ok, view, _} = live("/")
        assert render(view) =~ "Welcome to Phoenix!"

        capture_screenshot(view, "screenshot.png")
      end
  """
  def capture_screenshot(view, path, opts \\ []) do
    {namespace, opts} = Keyword.pop(opts, :namespace, PhoenixLiveViewTestScreenshots)

    Phoenix.LiveViewTest.open_browser(view, fn html ->
      Browser.capture_screenshot(namespace, path, html, opts)
      html
    end)
  end
end
