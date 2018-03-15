defmodule RegistrationLinkWeb.Router do
  use RegistrationLinkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth_layout do
    plug :put_layout, {RegistrationLinkWeb.LayoutView, :auth}
  end

  pipeline :login_required do
    plug RegistrationLink.Guardian.AuthPipeline.Browser
    plug RegistrationLink.Guardian.AuthPipeline.Authenticate
    plug RegistrationLinkWeb.Auth.CurrentUser
  end

  scope "/", RegistrationLinkWeb do
    pipe_through [:browser, :auth_layout]
    
    get "/", PageController, :index
 end

  scope "/", RegistrationLinkWeb do
    pipe_through [:browser, :login_required]

  end

  # Other scopes may use custom stacks.
  # scope "/api", RegistrationLinkWeb do
  #   pipe_through :api
  # end
end
