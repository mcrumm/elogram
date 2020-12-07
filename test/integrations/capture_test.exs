defmodule PhoenixLiveViewTestScreenshots.CaptureTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest

  import Phoenix.LiveViewTest
  import PhoenixLiveViewTest.CaptureScreenshot
  alias PhoenixLiveViewScreenshotsTest.{Endpoint}

  @endpoint Endpoint

  setup do
    {:ok, screenshots} = PhoenixLiveViewTestScreenshots.start(name: unique_screenshots_name())
    {:ok, live, _} = live(Phoenix.ConnTest.build_conn(), "/counter")
    %{live: live, screenshots: screenshots}
  end

  test "captures screenshots", %{live: view, screenshots: namespace} do
    assert render(view) =~ "count: 0"

    assert view |> capture_screenshot(path, namespace: namespace) == view
    assert File.exists?(Path.join([System.tmp_dir!(), path]))
  end

  def unique_screenshots_name do
    :"PhoenixLiveViewTestScreenshots#{System.unique_integer([:positive, :monotonic])}"
  end

  def unique_screenshot_name do
    "counter_live_screenshot_#{System.unique_integer([:positive, :monotonic])}.png"
  end
end
