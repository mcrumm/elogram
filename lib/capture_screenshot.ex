defmodule PhoenixLiveViewTest.CaptureScreenshot do
  @moduledoc """
  Functionality to capture LiveView screenshots for testing.
  """
  @doc """
  Captures a screenshot of a LiveView under test.

  ## Examples

      test "one thousand words" end
        {:ok, view, _} = live("/")
        assert render(view) =~ "Welcome to Phoenix!"

        capture_screenshot(view, "screenshot.png")
      end
  """
  def capture_screenshot(view, _path, _opts \\ []) do
    Phoenix.LiveViewTest.open_browser(view, fn tmp ->
      # TODO: capture screenshot
      tmp
    end)
  end
end
