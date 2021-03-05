defmodule LocalBroadcast.Application do
  @moduledoc false

  use Application

  @peer_broadcaster_name :mcam_peer_broadcast
  @mcam_peer_registry_name :mcam_peer_registry

  @impl true
  def start(_type, _args) do
    children = [
      LocalBroadcast.McamPeerRegistryEntrySupervisor,
      {Registry, keys: :duplicate, name: @peer_broadcaster_name},
      {Registry, keys: :unique, name: @mcam_peer_registry_name},
      {LocalBroadcast.McamPeerRegistry,
       registry_name: @mcam_peer_registry_name, name: LocalBroadcast.McamPeerRegistry},
      LocalBroadcast.BroadcasterSupervisor
    ]

    opts = [strategy: :one_for_one, name: LocalBroadcast.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def peer_broadcaster_name, do: @peer_broadcaster_name
  def mcam_peer_registry_name, do: @mcam_peer_registry_name
end
