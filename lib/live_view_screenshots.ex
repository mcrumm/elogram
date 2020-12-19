defmodule LiveViewScreenshots do
  @external_resource "README.md"
  @moduledoc @external_resource
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  alias LiveViewScreenshots.Server

  @doc """
  Starts a server to take screenshots in tests.
  """
  defdelegate start(options), to: Server, as: :start_link
end
