defmodule PhoenixLiveViewTestScreenshots.CaptureTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest

  import Phoenix.LiveViewTest
  import PhoenixLiveViewTest.CaptureScreenshot
  alias PhoenixLiveViewScreenshotsTest.{Endpoint}

  @endpoint Endpoint

  setup do
    {:ok, live, _} = live(Phoenix.ConnTest.build_conn(), "/counter")
    %{live: live}
  end

  test "captures screenshots", %{live: view} do
    assert render(view) =~ "count: 0"
    assert view |> capture_screenshot("counter/0.png") == view
  end
end
