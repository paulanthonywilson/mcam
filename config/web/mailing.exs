import Config

adapter = case Mix.env() do
  :test -> Bamboo.TestAdapter

  # Sending emails from dev because it's still fairly convenient right now
  _ -> Bamboo.MailgunAdapter
end

config :mcam_server, McamServer.Mailing.Mailer,
  adapter: adapter,
  from: "merecam@iscodebaseonfire.com",
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

secret_mail = Path.join(__DIR__, "mailing.secret.exs")

if File.exists?(secret_mail) do
  import_config(secret_mail)
end
