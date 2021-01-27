# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :mcam_server,
  ecto_repos: [McamServer.Repo]

# Overrride camera and browser tokens for prod (obvs)
config :mcam_server, :camera_token,
  secret: "zZlbrPr8Wpevh2L+90nz048s16VDlko4lEmcsVBH5XjsORaJjCSB49u2AZqlyOjk",
  salt: "8XYbBElUVi5HQu3yuvB2w/KMruFnTRGizWfsL5li/edqWMnk8+fycKY+bKkM/Zy2"

config :mcam_server, :browser_token,
  secret: "Yo3h+LdkfXBCNqeGiAUYE+ZSsY9KxfUmCvtnC5Skaa4E8hEiGXsCW6udWO7ZmIgY",
  salt: "9aTS+QnnFKSZ0j3MJZzjWW+cC3P7Y7wFprRw5tEYpFu2jDhOEJfRPy/szAo15HP7"

config :mcam_server_web,
  ecto_repos: [McamServer.Repo],
  generators: [context_app: :mcam_server]

# Configures the endpoint
config :mcam_server_web, McamServerWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 4600],
  secret_key_base: "uvo2dZbpu/NsUjSBsLx0HN8O+AoNtdCBmBRBLpXR9vY8x5pqZURTNGSjeUxapX7d",
  render_errors: [view: McamServerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: McamServer.PubSub,
  live_view: [signing_salt: "2FHTBXep"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "mailing.exs"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
