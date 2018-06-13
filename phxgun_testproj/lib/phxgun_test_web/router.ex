defmodule PhxgunTestWeb.Router do
  use PhxgunTestWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhxgunTestWeb do
    pipe_through :api
  end
end
