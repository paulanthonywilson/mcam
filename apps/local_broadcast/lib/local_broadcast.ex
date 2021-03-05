defmodule LocalBroadcast do
  @moduledoc false
  alias LocalBroadcast.McamPeerRegistry

  @doc """
  Subscribe the process to receive updates of merecam peers on the network. Updates take the form of
  messages below where "nerves-gg8f" is the host name on local IP 10.1.2.4.

  ```
    {:mcam_peer_registry, :update, {"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.4:4000"}}
  ```
  """
  @spec subscribe :: :ok
  def subscribe do
    McamPeerRegistry.subscribe(McamPeerRegistry)
  end

  @doc """
  List currently seen local peers on the network. Takes the form:any()

  ```
  [{"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.4:4000"}]
  ```
  """
  def peers do
    McamPeerRegistry.peers(McamPeerRegistry)
  end
end
