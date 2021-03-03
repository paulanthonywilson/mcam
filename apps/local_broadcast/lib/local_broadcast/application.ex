defmodule LocalBroadcast.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {LocalBroadcast.Worker, arg}
      {LocalBroadcast.Broadcaster, [name: LocalBroadcast.Broadcaster]}
    ]

    opts = [strategy: :one_for_one, name: LocalBroadcast.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
