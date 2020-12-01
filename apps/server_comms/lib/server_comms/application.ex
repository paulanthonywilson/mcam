defmodule ServerComms.Application do
  @moduledoc false

  use Application

  # Restart everything if we don't send an image
  # within 30 secs
  @send_image_timeout 30_000

  # Restart ever couple of days anyway - there's no harm and it helps
  # ensure a token refresh
  @one_day_in_milliseconds 1_000 * 60 * 60 * 24
  @long_restart @one_day_in_milliseconds * 2

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec(
        {ServerComms.Ws.Tick,
         [timeout: @send_image_timeout, name: :server_comms_send_image_tick]},
        id: :send_image_tick
      ),
      Supervisor.child_spec(
        {ServerComms.Ws.Tick, [timeout: @long_restart, name: :server_comms_ws_long_restart]},
        id: :long_restart
      ),
      ServerComms.Ws.WebsocketConnector
    ]

    opts = [
      strategy: :one_for_all,
      name: ServerComms.Supervisor,
      max_restarts: 100,
      max_seconds: 1
    ]

    Supervisor.start_link(children, opts)
  end
end
