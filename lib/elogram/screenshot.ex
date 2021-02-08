defmodule Elogram.Screenshot do
  @moduledoc """
  A structure for capturing a screenshot.
  """
  if Version.match?(System.version(), ">= 1.8.0") do
    @derive {Inspect,
             only: [
               :browser,
               :name,
               :save_path,
               :captured_bytes,
               :captured_path,
               :error
             ]}
  end

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

  @doc """
  Builds a `#{inspect(__MODULE__)}`.
  """
  def new(url, name) when is_binary(url) and is_binary(name) do
    %__MODULE__{name: name, url: url}
  end
end
