import Config

config :mcam_server, McamServer.Accounts.UserNotifier,
  adapter: Bamboo.MailgunAdapter,
  api_key: {:system, "MAILGUN_API_KEY"},
  domain: {:system, "MAILGUN_DOMAIN"},
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

secret_mail = Path.join(__DIR__, "mailing.secret.exs")

if File.exists?(secret_mail) do
  import_config(secret_mail)
end
