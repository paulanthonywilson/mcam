use Mix.Config

config :cam_web,
  generators: [context_app: :cam]

# Configures the endpoint
config :cam_web, CamWeb.Endpoint,
  # url: [host: "localhost"],
  http: [port: 4000],
  secret_key_base: "XbhW49X8QLcAmwESamoi7f7mBruBEFnDFo5iSUV4w2xWiBdpR5ukV/uLxGECBc5D",
  render_errors: [view: CamWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Cam.PubSub,
  check_origin: false,
  live_view: [signing_salt: "ezrEqi9x"],
  server: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :logger, :console, format: "[$level] $message\n"

if Mix.env() == :test do
  config :cam_web, CamWeb.Endpoint,
    http: [port: 4002],
    server: false
end

if Mix.target() == :host && Mix.env() == :dev do
  config :cam_web, CamWeb.Endpoint,
    debug_errors: true,
    code_reloader: true,
    check_origin: false,
    watchers: [
      node: [
        "node_modules/webpack/bin/webpack.js",
        "--mode",
        "development",
        "--watch-stdin",
        cd: Path.expand("../assets", __DIR__)
      ]
    ]
end

# if Mix.target() != :host do
#   config :cam_web, CamWeb.Endpoint, http: [port: 80]
# end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# import_config "#{Mix.env()}.exs"
