defmodule AuthWeb.Router do
  use AuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Auth.Guardian.AuthPipeline.Browser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AuthWeb do
    pipe_through :browser # Use the default browser stack

    get "/", SessionController, :index
    get "/authorize", SessionController, :authorize
    get "/logout", SessionController, :logout
    post "/sign_in", SessionController, :login

    get "/demo", DemoController, :index
    get "/demo/token/:code", DemoController, :token


    scope "/:consent" do
      get "/accept", SessionController, :accept
      get "/deny", SessionController, :deny
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", AuthWeb.API do
    pipe_through :api

    scope "/client" do
      post "/request", ClientController, :request
    end
  end
end
