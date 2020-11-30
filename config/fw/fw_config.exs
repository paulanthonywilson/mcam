import Config

apps_dir = Path.join(__DIR__, "../../apps")

# make Nerves work
import_config "#{apps_dir}/fw/config/config.exs"

# Keep the Phoenix config self contained
import_config "#{apps_dir}/cam_web/config/config.exs"

config :configure, :wifi_wizard_gpio_pin, 17

camera =
  if Mix.target() == :host do
    Camera.FakeCam
  else
    Camera.RealCam
  end

config :camera, Camera.Cam, camera

config :direct_image_sender, :cowboy_options, port: if(Mix.env() == :test, do: 5000, else: 4500)

# Secret stuff to avoid relying on all the `.env` things
if File.exists?(Path.join(__DIR__, "config.secret.exs")) do
  import_config "config.secret.exs"
end

if Mix.env() == :test do
  config :logger, :console, level: :warn
  config :server_comms, :registration_jwk, "test-secret"
end
