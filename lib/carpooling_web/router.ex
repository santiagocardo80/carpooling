defmodule CarpoolingWeb.Router do
  use CarpoolingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CarpoolingWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CarpoolingWeb do
    pipe_through :browser

    live "/", RideLive.Index, :index
    live "/rutas/nueva", RideLive.Index, :new
    live "/rutas/:id/editar", RideLive.Index, :edit
    live "/rutas/:id/verificar", ConfirmationActionLive, :ride_verify
    live "/rutas/:id/eliminar", ConfirmationActionLive, :ride_delete

    live "/rutas/:id", RideLive.Show, :show

    live "/usuario/:id/verificar", ConfirmationActionLive, :user_verify
    live "/usuario/:id/eliminar", ConfirmationActionLive, :user_delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", CarpoolingWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CarpoolingWeb.Telemetry
    end
  end
end
