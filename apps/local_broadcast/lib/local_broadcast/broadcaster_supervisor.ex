defmodule LocalBroadcast.BroadcasterSupervisor do
  @moduledoc """
  Associates the `LocalBroadcast.Broadcaster` with a `Common.Tick` for a complete restart
  should it look like the socket is dead.
  """
  use Supervisor


  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Common.Tick, [timeout: 30_000, name: :local_broadcast_peers_tick]},
      {LocalBroadcast.Broadcaster, [name: LocalBroadcast.Broadcaster]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
