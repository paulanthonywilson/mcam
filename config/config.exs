import Config

{server_url, server_ws} =
  case {Mix.env(), Mix.target()} do
    {:dev, :host} -> {"http://localhost:4600", "ws://localhost:4601"}
    {:dev, _} -> {"http://192.168.0.11:4600", "ws://192.168.0.11:4601"}
    _ -> {"https://mcam.iscodebaseonfire.com", "wss://mcam.iscodebaseonfire.com"}
  end

config :common, server_url: server_url, server_ws: server_ws

IO.inspect(Mix.target(), label: "*******************")

case Mix.target() do
  :web ->
    import_config "./web/web_config.exs"

  :rpi0 ->
    import_config "./fw/fw_config.exs"

  _ ->
    import_config "./fw/fw_config.exs"
    import_config "./web/web_config.exs"
end
