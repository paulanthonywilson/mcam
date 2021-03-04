defmodule LocalBroadcast.Events do
  @moduledoc """
  Event subscription and notifications associated with finding out about peers
  """

  import LocalBroadcast.Application, only: [peer_broadcaster_name: 0]

  def subscribe(topic) do
    {:ok, _} = Registry.register(peer_broadcaster_name(), topic, [])
    :ok
  end

  def broadcast(topic, event) do
    Registry.dispatch(peer_broadcaster_name(), topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, event)
    end)
  end
end
