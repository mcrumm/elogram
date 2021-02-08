defmodule Elogram do
  @external_resource "README.md"
  @moduledoc @external_resource
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  alias Elogram.{Screenshot, Server}

  @doc """
  Starts a server to take screenshots in tests.
  """
  defdelegate start(options), to: Server, as: :start_link

  @doc """
  Builds a new `#{inspect(__MODULE__.Screenshot)}`.
  """
  defdelegate screenshot(url, name), to: Screenshot, as: :new

  @doc """
  Captures a screenshot
  """
  defdelegate capture!(screenshot, server), to: Server
end
