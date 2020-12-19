defmodule LiveViewScreenshotsTest.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :setup_session do
    plug Plug.Session,
      store: :cookie,
      key: "_live_view_key",
      signing_salt: "/5pnMffsfdsDEV"

    plug :fetch_session
  end

  pipeline :browser do
    plug :setup_session
    plug :accepts, ["html"]
    plug :fetch_live_flash
  end

  scope "/", LiveViewScreenshotsTest do
    pipe_through [:browser]

    live "/counter", CounterLive
  end
end
