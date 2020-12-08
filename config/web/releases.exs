import Config

env_int = fn key ->
  key
  |> System.fetch_env!()
  |> String.to_integer()
end

config :mcam_server, :camera_token,
  secret: System.fetch_env!("MCAM_CAMERA_SECRET"),
  salt: System.fetch_env!("MCAM_CAMERA_SALT")

config :mcam_server, :browser_token,
  secret: System.fetch_env!("MCAM_BROWSER_SECRET"),
  salt: System.fetch_env!("MCAM_BROWSER_SALT")

config :mcam_server_web, McamServerWeb.Endpoint,
  secret_key_base: System.fetch_env!("MCAM_SECRET_KEY_BASE"),
  live_view: [signing_salt: System.fetch_env!("MCAM_LIVE_SALT")]

config :mcam_server, McamServer.Repo,
  url: System.get_env("MCAM_DATABASE_URL"),
  pool_size: String.to_integer(System.fetch_env!("MCAM_POOL_SIZE") || "10")

config :mcam_server, McamServer.Mailing.Mailer,
  api_key: System.fetch_env!("MCAM_MAILGUN_API_KEY"),
  domain: System.fetch_env!("MCAM_MAILGUN_DOMAIN")
