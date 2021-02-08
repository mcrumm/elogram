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

          assert view
                 |> capture_screenshot(name: "welcome.png")
                 |> render() =~ "Welcome to Phoenix!"
        end
      end
  """
  def capture_screenshot(view_or_element, opts \\ []) do
    name = opts[:name] || raise ArgumentError, "name is required for capture_screenshot/2"

    Phoenix.LiveViewTest.open_browser(view_or_element, fn html ->
      "file://#{html}"
      |> Elogram.Screenshot.new(name)
      |> Elogram.capture!(opts[:browser] || Elogram)
    end)
  end
end
