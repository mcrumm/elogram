defmodule Elogram.CaptureTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest

  import Phoenix.LiveViewTest
  import Elogram.CaptureScreenshot
  alias ElogramTest.Endpoint

  @endpoint Endpoint

  setup do
    %{name: server_name, save_path: save_path} = start_server!()
    {:ok, live, _} = live(Phoenix.ConnTest.build_conn(), "/counter")

    %{live: live, screenshots: server_name, save_path: save_path}
  end

  test "captures screenshots", %{live: view, screenshots: server, save_path: save_path} do
    clean_tmp_screenshots([
      Path.join([save_path, "counter_live_0.png"]),
      Path.join([save_path, "counter_live_1.png"]),
      Path.join([save_path, "counter_live_2.png"])
    ])

    assert render(view) =~ "count: 0"

    assert view |> capture_screenshot(name: "counter_live_0.png", browser: server) == view
    assert [save_path, "counter_live_0.png"] |> Path.join() |> File.exists?()

    assert view |> element("button", "Increment") |> render_click() =~ "count: 1"
    assert view |> capture_screenshot(name: "counter_live_1.png", browser: server) == view
    assert [save_path, "counter_live_1.png"] |> Path.join() |> File.exists?()

    assert view |> element("button", "Increment") |> render_click() =~ "count: 2"
    assert view |> capture_screenshot(name: "counter_live_2.png", browser: server) == view
    assert [save_path, "counter_live_2.png"] |> Path.join() |> File.exists?()
  end

  test "save to nested path", %{live: view, screenshots: server, save_path: save_path} do
    clean_tmp_screenshots([Path.join([save_path, "nested/path/counter_live_0.png"])])
    assert render(view) =~ "count: 0"

    assert view |> capture_screenshot(name: "nested/path/counter_live_0.png", browser: server) ==
             view

    assert [save_path, "nested/path/counter_live_0.png"] |> Path.join() |> File.exists?()
  end

  test "handle server init error" do
    import ExUnit.CaptureIO

    opts = [name: unique_server_name(), port: "0000"]

    capture_io(:stderr, fn ->
      assert {:error, {:chrome_error, _}} =
               start_supervised({Elogram.Server, opts}, id: :server_error)
    end) =~ "Error connecting to Chrome"
  end

  defp start_server!(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new_lazy(:name, &unique_server_name/0)
      |> Keyword.put_new(:save_path, "tmp/screenshots")

    pid = start_supervised!({Elogram.Server, opts})

    %{pid: pid, name: opts[:name], save_path: opts[:save_path]}
  end

  defp unique_server_name do
    :"Elogram#{System.unique_integer([:positive, :monotonic])}"
  end

  # Clean up tmp screenshots dir to make sure tests doesn't return false positives.
  # Note: Delete screenshots _before_ each test instead of `on_exit` because we may need to inspect the actual files.
  defp clean_tmp_screenshots(files) do
    Enum.each(files, &File.rm(&1))
  end
end
