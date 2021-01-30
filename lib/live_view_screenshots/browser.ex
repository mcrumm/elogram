defmodule LiveViewScreenshots.Browser do
  @moduledoc """
  The Browser process manages communication with a headless Chrome OS process.
  """
  @behaviour NimblePool
  alias ChromeRemoteInterface.{PageSession, Session}
  alias ChromeRemoteInterface.RPC.Page

  @impl NimblePool
  def init_pool(arg) do
    case ensure_browser_is_running(arg) do
      {:ok, server} -> {:ok, %{server: server, save_path: arg[:save_path]}}
      {:error, reason} -> {:stop, reason}
    end
  end

  defp ensure_browser_is_running(%{host: host, port: port}) do
    with server = Session.new(host: host, port: port),
         {:ok, _vsn} <- Session.version(server) do
      {:ok, server}
    end
  end

  @impl NimblePool
  def init_worker(state) do
    with {:ok, page} <- Session.new_page(state.server),
         {:ok, page_pid} <- PageSession.start_link(page) do
      {:ok, _} = Page.enable(page_pid)
      {:ok, page_pid, state}
    end
  end

  @page_load_event "Page.loadEventFired"
  @impl NimblePool
  # Subscribe the caller to the Page events
  def handle_checkout({:checkout, path}, {subscriber_pid, _}, page_pid, pool_state)
      when is_pid(page_pid) do
    :ok = PageSession.subscribe(page_pid, @page_load_event, subscriber_pid)
    joined_path = Path.join([pool_state.save_path, path])

    {:ok, {page_pid, joined_path}, page_pid, pool_state}
  end

  @impl NimblePool
  # Unsubscribe the caller from Page events
  def handle_checkin(:ok, {subscriber_pid, _}, page_pid, pool_state) do
    :ok = PageSession.unsubscribe_all(page_pid, subscriber_pid)

    {:ok, page_pid, pool_state}
  end

  def handle_checkin(:close, _from, _page, pool_state) do
    {:remove, :closed, pool_state}
  end
end
