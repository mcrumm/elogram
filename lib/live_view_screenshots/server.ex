defmodule LiveViewScreenshots.Server do
  # Server to drive a headless chrome page.
  @moduledoc false
  alias ChromeRemoteInterface
  alias LiveViewScreenshots.{Browser, FS, Screenshot}

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
    browser = Browser.new!(opts)

    NimblePool.start_link(
      lazy: true,
      name: pool_name,
      pool_size: pool_size,
      worker: {Browser, browser}
    )
  end

  @doc """
  Captures the screenshot and saves it to disk.
  """
  def capture!(%Screenshot{} = screenshot, browser, opts \\ []) do
    %Screenshot{screenshot | browser: browser}
    |> Browser.capture!(opts)
    |> FS.save_to_disk!(opts)
    |> handle_error()
  end

  defp handle_error(%Screenshot{error: nil} = screenshot), do: screenshot

  defp handle_error(screenshot) do
    IO.warn("""
      Error capturing screenshot to #{screenshot.path}:

      #{inspect(screenshot.error)}

    """)

    screenshot
  end
end
