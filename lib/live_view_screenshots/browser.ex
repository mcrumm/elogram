defmodule LiveViewScreenshots.Browser do
  @moduledoc """
  The Browser process manages communication with a headless Chrome OS process.
  """
  @behaviour NimblePool
  alias ChromeRemoteInterface.{PageSession, RPC.Page, Session}
  alias LiveViewScreenshots.Screenshot

  defstruct host: "localhost", port: 9222, save_path: "tmp/screenshots"

  @page_load_event "Page.loadEventFired"

  @doc """
  Builds a new `#{inspect(__MODULE__)}`.
  """
  def new!(opts) do
    browser = struct(__MODULE__, opts)
    validate_save_path!(browser)
    browser
  end

  defp validate_save_path!(%__MODULE__{save_path: path}) do
    # TODO: validation
    File.mkdir_p!(path)
  end

  @doc """
  Captures the image bytes for the screenshot.
  """
  def capture!(%Screenshot{} = screenshot, opts) do
    pool_timeout = Keyword.get(opts, :pool_timeout, 5000)

    screenshot
    |> screenshot_for_pool()
    |> NimblePool.checkout!(
      :checkout,
      fn _, {page, save_path} ->
        %Screenshot{screenshot | page_pid: page, save_path: save_path, subscriber_pid: self()}
        |> navigate_capture_loop(opts)
        |> handle_result()
      end,
      pool_timeout
    )
    |> Map.update!(:captured_bytes, &Base.decode64!/1)
  end

  defp screenshot_for_pool(%Screenshot{browser: browser}) when not is_nil(browser),
    do: :"#{browser}.Pool"

  defp navigate_capture_loop(%Screenshot{} = screenshot, opts) do
    receive_timeout = Keyword.get(opts, :receive_timeout, 2000)
    :ok = navigate(screenshot)
    capture_loop(screenshot, receive_timeout)
  end

  defp capture_loop(%Screenshot{} = screenshot, timeout) do
    receive do
      {:chrome_remote_interface, @page_load_event, _data} ->
        :ok = capture_screenshot(screenshot)
        capture_loop(screenshot, timeout)

      {:chrome_remote_interface, "Page.captureScreenshot", %{"result" => %{"data" => data}}} ->
        %Screenshot{screenshot | captured_bytes: data}
    after
      timeout -> exit(:receive_timeout)
    end
  end

  defp handle_result(%Screenshot{error: nil} = screenshot), do: {screenshot, :ok}
  defp handle_result(%Screenshot{error: reason}), do: {{:error, reason}, :close}

  ## Pool stuff

  @impl NimblePool
  def init_pool(%__MODULE__{} = browser) do
    case ensure_browser_is_running(browser) do
      {:ok, _} = ok ->
        ok

      {:error, reason} ->
        IO.warn("""
          Error connecting to Chrome at #{browser.host}:#{browser.port}, reason:

          #{inspect(reason)}

        """)

        {:stop, :chrome_error}
    end
  end

  defp ensure_browser_is_running(%__MODULE__{} = browser) do
    with {:ok, _vsn} <- Session.version(browser) do
      {:ok, browser}
    end
  end

  @impl NimblePool
  def init_worker(browser) do
    async = fn ->
      # TODO: add back-off
      {:ok, page} = Session.new_page(browser)
      {:ok, page_pid} = PageSession.start_link(page)
      Page.enable(page_pid)
      page_pid
    end

    {:async, async, browser}
  end

  @impl NimblePool
  def handle_checkout(:checkout, {subscriber_pid, _}, page_pid, browser) when is_pid(page_pid) do
    PageSession.subscribe(page_pid, @page_load_event, subscriber_pid)
    {:ok, {page_pid, browser.save_path}, page_pid, browser}
  end

  @impl NimblePool
  def handle_checkin(:ok, {subscriber_pid, _}, page_pid, pool_state) do
    PageSession.unsubscribe_all(page_pid, subscriber_pid)
    {:ok, page_pid, pool_state}
  end

  def handle_checkin(:close, _from, _page, pool_state) do
    {:remove, :closed, pool_state}
  end

  ## DevTools Page API
  defp navigate(%Screenshot{} = screenshot) do
    Page.navigate(
      screenshot.page_pid,
      %{url: screenshot.url},
      async: screenshot.subscriber_pid
    )
  end

  defp capture_screenshot(%Screenshot{} = screenshot) do
    Page.captureScreenshot(
      screenshot.page_pid,
      %{},
      async: screenshot.subscriber_pid
    )
  end
end
