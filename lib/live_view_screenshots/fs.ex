defmodule Elogram.FS do
  # File system helpers
  @moduledoc false
  alias Elogram.Screenshot

  def save_to_disk!(screenshot, opts \\ [])

  def save_to_disk!(
        %Screenshot{captured_bytes: bytes, name: name, save_path: path} = screenshot,
        _opts
      )
      when not is_nil(name) and not is_nil(path) and not is_nil(bytes) do
    screenshot_path = Path.join([path, name])

    with :ok <- save_screenshot_on_disk(screenshot_path, bytes) do
      %Screenshot{screenshot | captured_path: screenshot_path}
    end
  end

  def save_to_disk!(screenshot, _opts) do
    raise ArgumentError, """
    Expected a captured screenshot with name and save_path, got:

    #{inspect(screenshot)}
    """
  end

  defp save_screenshot_on_disk(path, contents) do
    with dir = Path.dirname(path),
         :ok <- File.mkdir_p(dir) do
      File.write!(path, contents)
    end
  end
end
