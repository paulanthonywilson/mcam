defmodule ServerComms.Events do
  @moduledoc """
  Subscribing and broadcasting connection events
  """

  import Configure.Events, only: [pubsub_name: 0]
  alias Phoenix.PubSub

  @topic "server-connection-status"

  @doc """
  Subscribe to server status change updates
  """
  @spec subscribe :: :ok | {:error, {:already_registered, pid}}
  def subscribe do
    PubSub.subscribe(pubsub_name(), @topic)
  end

  @doc """
  Broadcast that the status has changed
  """
  @spec broadcast_status_changed(any) :: :ok | {:error, any}
  def broadcast_status_changed(status) do
    PubSub.broadcast(pubsub_name(), @topic, {:server_connection_status_changed, status})
  end
end
