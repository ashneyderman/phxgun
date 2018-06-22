use Mix.Config

config :phxgun_test, PhxgunTestWeb.Endpoint,
  http: [port: 4000],
  secret_key_base: "UrKF/EyPwPEJgHPA+FPfrl73+/eXEyLG6j4VQWFUdh8dpELMQAcQor0Tn4KfVcwV",
  render_errors: [view: PhxgunTestWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: PhxgunTest.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix, :serve_endpoints, true


# config :exometer_core, 
#   report: [reporters: [{:exometer_report_tty1, [:test]}]]

# config :elixometer,
#   reporter: :exometer_report_tty1,
#   update_frequency: 5_000,
#   env: Mix.env,
#   metric_prefix: "phxgun",
#   excluded_datapoints: [:median, 999]
