defmodule LiveViewScreenshots.Screenshot do
  @type t :: %__MODULE__{
          :name => String.t(),
          :url => String.t(),
          :save_path => String.t() | nil,
          :browser => atom() | pid() | nil,
          :page_pid => pid() | nil,
          :subscriber_pid => pid() | nil,
          :captured_bytes => :binary | nil,
          :captured_path => String.t() | nil,
          :error => nil | term()
        }

  @enforce_keys [:name, :url]
  defstruct [
    :name,
    :save_path,
    :url,
    :browser,
    :page_pid,
    :subscriber_pid,
    :captured_bytes,
    :captured_path,
    :error
  ]

  @default_name "screenshot.png"

  @doc """
  Builds a `#{inspect(__MODULE__)}`.
  """
  def new(url, name \\ @default_name) when is_binary(url) and is_binary(name) do
    %__MODULE__{name: name, url: url}
  end
end
