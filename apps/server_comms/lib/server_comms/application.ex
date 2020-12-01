defmodule ServerComms.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ServerComms.Ws.WebsocketConnector
    ]

    opts = [
      strategy: :one_for_one,
      name: ServerComms.Supervisor,
      max_restarts: 100,
      max_seconds: 1
    ]

    Supervisor.start_link(children, opts)
  end
end
