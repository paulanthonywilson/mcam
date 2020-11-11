defmodule CamWeb.Router do
  use CamWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CamWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CamWeb do
    pipe_through :browser

    live "/", CameraLive, :index
    live "/network", NetworkLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CamWeb do
  #   pipe_through :api
  # end

  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through :browser
    live_dashboard "/dashboard", metrics: CamWeb.Telemetry
  end
end
