import Config

case Mix.target() do
  :host ->
    import_config "./fw/fw_config.exs"
    import_config "./web/web_config.exs"

  :web ->
    import_config "./web/web_config.exs"

  :rpi0 ->
    import_config "./fw/fw_config.exs"
end
