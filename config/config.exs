import Config

# make Nerves work
import_config "../apps/fw/config/config.exs"

# Secret stuff to avoid relying on all the `.env` things

if File.exists?(Path.join(__DIR__, "config.secret.exs")) do
  import_config "config.secret.exs"
end
