defmodule PhoenixLiveViewScreenshotsTest.CounterLive do
  use Phoenix.LiveView, namespace: PhoenixLiveViewScreenshotsTest

  def render(assigns) do
    ~L"""
    <p>count: <%= @count %><p>
    <button phx-click="count++">&plus;&plus;</button>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("count++", _, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end
end
