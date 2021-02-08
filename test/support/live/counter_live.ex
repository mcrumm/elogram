defmodule ElogramTest.CounterLive do
  use Phoenix.LiveView, namespace: ElogramTest

  def render(assigns) do
    ~L"""
    <p>count: <%= @count %></p>
    <button phx-click="count++">Increment</button>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("count++", _, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end
end
