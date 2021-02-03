defmodule LiveViewScreenshots.Server do
  # Server to drive a headless chrome page.
  @moduledoc false
  alias ChromeRemoteInterface
  alias ChromeRemoteInterface.RPC.Page

  @default_save_path "tmp/screenshots"

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts) do
    name = Keyword.get(opts, :name, LiveViewScreenshots)
    pool_name = :"#{name}.Pool"
    pool_size = Keyword.get_lazy(opts, :pool_size, &System.schedulers_online/0)
    host = Keyword.get(opts, :host, "localhost")
    port = Keyword.get(opts, :port, 9222)

    worker_state =
      case validate(opts, :save_path) do
        {:ok, save_path} ->
          %{host: host, port: port, save_path: save_path}

        {:error, reason} ->
          raise reason
      end

    NimblePool.start_link(
      lazy: true,
      name: pool_name,
      pool_size: pool_size,
      worker: {LiveViewScreenshots.Browser, worker_state}
    )
  end

  @page_load_event "Page.loadEventFired"
  @doc """
  Captures a screenshot.
  """
  def capture_screenshot(url, path, server, opts \\ []) do
    pool_timeout = Keyword.get(opts, :pool_timeout, 5000)
    receive_timeout = Keyword.get(opts, :receive_timeout, 15000)

    NimblePool.checkout!(
      :"#{server}.Pool",
      {:checkout, path},
      fn _, {page, joined_path} ->
        {:ok, _} = Page.navigate(page, %{url: "file://#{url}"})

        receive do
          {:chrome_remote_interface, @page_load_event, _data} ->
            case take_screenshot(page, joined_path, opts) do
              {:ok, _} = ok -> {ok, :ok}
              error -> {error, :close}
            end
        after
          receive_timeout ->
            exit(:receive_timeout)
        end
      end,
      pool_timeout
    )
  end

  defp take_screenshot(page, path, opts) do
    with {:ok, image} <- capture_decode_screenshot(page, opts),
         :ok <- save_screenshot_on_disk(path, image) do
      {:ok, path}
    else
      {:error, error} -> handle_error(error, path)
    end
  end

  # Capture and decode the raw screenshot data
  defp capture_decode_screenshot(page, _opts) do
    with {:ok, %{"result" => %{"data" => bytes}}} <- Page.captureScreenshot(page) do
      Base.decode64(bytes)
    end
  end

  defp handle_error(error, path) do
    IO.warn("""
      Error capturing screenshot to #{path}:

      #{inspect(error)}

    """)
  end

  defp save_screenshot_on_disk(path, contents) do
    with dir = Path.dirname(path),
         :ok <- File.mkdir_p(dir) do
      File.write(path, contents)
    end
  end

  defp validate(options, :save_path) do
    path = save_path(options)

    case File.mkdir_p(path) do
      :ok -> {:ok, path}
      error -> error
    end
  end

  defp save_path(options) do
    Keyword.get(options, :save_path, @default_save_path)
  end
end
