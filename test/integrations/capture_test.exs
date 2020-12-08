defmodule PhoenixLiveViewTestScreenshots.CaptureTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest

  import Phoenix.LiveViewTest
  import PhoenixLiveViewTest.CaptureScreenshot
  alias PhoenixLiveViewScreenshotsTest.{Endpoint}

  @endpoint Endpoint

  setup do
    {:ok, _pid} =
      PhoenixLiveViewTestScreenshots.start(
        name: screenshots_name = unique_screenshots_name(),
        save_path: save_path = Path.absname("tmp/screenshots")
      )

    {:ok, live, _} = live(Phoenix.ConnTest.build_conn(), "/counter")
    %{live: live, screenshots: screenshots_name, save_path: save_path}
  end

  test "captures screenshots", %{live: view, screenshots: namespace, save_path: save_path} do
    assert render(view) =~ "count: 0"

    assert view |> capture_screenshot("counter_live_0.png", namespace: namespace) == view
    assert File.exists?(Path.join([save_path, "counter_live_0.png"]), [:raw])
  end

  def unique_screenshots_name do
    :"PhoenixLiveViewTestScreenshots#{System.unique_integer([:positive, :monotonic])}"
  end

  def unique_screenshot_name do
    "counter_live_screenshot_#{System.unique_integer([:positive, :monotonic])}.png"
  end
end
