# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :phxgun_test, PhxgunTestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UrKF/EyPwPEJgHPA+FPfrl73+/eXEyLG6j4VQWFUdh8dpELMQAcQor0Tn4KfVcwV",
  render_errors: [view: PhxgunTestWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: PhxgunTest.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
