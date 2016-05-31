defmodule ChatBot.Router do
  use ChatBot.Web, :router

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

  pipeline :webhook do
    plug :accepts, ["json"]
  end

  scope "/", ChatBot do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/", ChatBot do
     pipe_through :api

     post "/authenticate", PageController, :authenticate
  end

  scope "/webhook", ChatBot do
    pipe_through :webhook

    get "/fb-messenger", FacebookController, :verify
    post "/fb-messenger", FacebookController, :handle_in
  end
end
