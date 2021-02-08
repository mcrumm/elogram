defmodule Elogram.CaptureScreenshot do
  @moduledoc """
  Functionality to capture LiveView screenshots for debugging.
  """

  @doc """
  Captures a screenshot of a LiveView under test.

  ## Examples

      defmodule MyAppWeb.PageLiveTest do
        use MyAppWeb, :live_view
        import Elogram.CaptureScreenshot

        test "a thousand words", %{conn: conn} end
          {:ok, view, _} = live(conn, "/")
          assert render(view) =~ "Welcome to Phoenix!"

          capture_screenshot(view, "screenshot.png")
        end
      end
  """
  def capture_screenshot(view_or_element, name) do
    capture_screenshot(Elogram, view_or_element, name)
  end

  @doc """
  See `capture_screenshot/2` for options.
  """
  def capture_screenshot(server, view_or_element, name) when is_atom(server) do
    Phoenix.LiveViewTest.open_browser(view_or_element, fn html ->
      "file://#{html}"
      |> Elogram.screenshot(name)
      |> Elogram.capture!(server)
    end)
  end
end
