defmodule PhoenixLiveViewTestScreenshots do
  @moduledoc """
  Helpers for `Phoenix.LiveViewTest` to capture screenshots.
  """
  alias PhoenixLiveViewTestScreenshots.Browser

  defdelegate start(options), to: Browser, as: :start_link
end

defmodule PhoenixLiveViewTestScreenshots.Screenshot do
  defstruct [
    :browser_pid,
    :html_path,
    :screenshot_path
  ]
end

defmodule PhoenixLiveViewTestScreenshots.Browser do
  use GenServer
  alias ChromeRemoteInterface

  def start_link(arg) do
    name = arg[:name] || PhoenixLiveViewTestScreenshots
    GenServer.start_link(__MODULE__, arg, name: name)
  end

  @impl true
  def init(options) do
    with {:ok, save_path} <- validate(options, :save_path, "tmp/screenshots"),
         server = ChromeRemoteInterface.Session.new(options),
         {:ok, page} <- ChromeRemoteInterface.Session.new_page(server),
         {:ok, pid} <- ChromeRemoteInterface.PageSession.start_link(page) do
      {:ok, %{server: server, page: page, page_pid: pid, save_path: save_path}}
    end
  end

  def capture_screenshot(browser, path, html, opts) do
    GenServer.call(browser, {:screenshot, path, html, opts})
  end

  @impl true
  def handle_call({:screenshot, path, html, opts}, _from, state) do
    joined_path = Path.join([state.save_path, path])
    result = take_screenshot(state.page_pid, joined_path, html, opts)
    {:reply, result, state}
  end

  defp take_screenshot(pid, path, html, opts) do
    # Navigate to the html file
    {:ok, nav} = navigate(pid, to: "file://#{html}")

    with {:ok, image} <- capture_decode_screenshot(pid, opts),
         :ok <- File.write(path, image) do
      {:ok, %{nav: nav["result"], screenshot: path}}
    else
      {:error, error} -> handle_error(error, path)
    end
  end

  defp navigate(pid, opts) do
    ChromeRemoteInterface.RPC.Page.navigate(pid, %{url: opts[:to]})
  end

  defp capture_decode_screenshot(pid, _opts) do
    # Capture and decode the raw screenshot data
    with {:ok, %{"result" => %{"data" => bytes}}} <-
           ChromeRemoteInterface.RPC.Page.captureScreenshot(pid) do
      Base.decode64(bytes)
    end
  end

  defp handle_error(error, path) do
    IO.warn("""
      Error capturing screenshot to #{path}:

      #{inspect(error)}

    """)
  end

  defp validate(options, :save_path, default) do
    with path = Keyword.get(options, :save_path, default),
         :ok <- File.mkdir_p(path) do
      {:ok, path}
    end
  end
end
