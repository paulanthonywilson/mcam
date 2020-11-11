import Config

# make Nerves work
import_config "../apps/fw/config/config.exs"

# Keep the Phoenix config self contained
import_config "../apps/cam_web/config/config.exs"

config :configure, :wifi_wizard_gpio_pin, 17

# Secret stuff to avoid relying on all the `.env` things
if File.exists?(Path.join(__DIR__, "config.secret.exs")) do
  import_config "config.secret.exs"
end
