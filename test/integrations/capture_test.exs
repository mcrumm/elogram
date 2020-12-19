defmodule PhoenixLiveViewTestScreenshots.CaptureTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest

  import Phoenix.LiveViewTest
  import LiveViewScreenshots.CaptureScreenshot
  alias LiveViewScreenshotsTest.Endpoint

  @endpoint Endpoint

  setup do
    %{name: server_name, save_path: save_path} = start_server!()
    {:ok, live, _} = live(Phoenix.ConnTest.build_conn(), "/counter")
    %{live: live, screenshots: server_name, save_path: save_path}
  end

  test "captures screenshots", %{live: view, screenshots: server, save_path: save_path} do
    assert render(view) =~ "count: 0"

    assert server |> capture_screenshot(view, "counter_live_0.png") == view
    assert [save_path, "counter_live_0.png"] |> Path.join() |> File.exists?()

    assert view |> element("button", "Increment") |> render_click() =~ "count: 1"
    assert server |> capture_screenshot(view, "counter_live_1.png") == view
    assert [save_path, "counter_live_1.png"] |> Path.join() |> File.exists?()

    assert view |> element("button", "Increment") |> render_click() =~ "count: 2"
    assert server |> capture_screenshot(view, "counter_live_2.png") == view
    assert [save_path, "counter_live_2.png"] |> Path.join() |> File.exists?()
  end

  defp start_server!(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new_lazy(:name, &unique_server_name/0)
      |> Keyword.put_new(:save_path, "tmp/screenshots")

    pid = start_supervised!({LiveViewScreenshots.Server, opts})

    %{pid: pid, name: opts[:name], save_path: opts[:save_path]}
  end

  defp unique_server_name do
    :"LiveViewScreenshots#{System.unique_integer([:positive, :monotonic])}"
  end
end
