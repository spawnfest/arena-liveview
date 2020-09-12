defmodule ArenaLiveviewWeb.Router do
  use ArenaLiveviewWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ArenaLiveviewWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ArenaLiveviewWeb.Room do
    pipe_through :browser

    live "/", NewLive, :new
    live "/room/:slug", ShowLive, :show
  end
end
