defmodule LocalBroadcast.McamPeerRegistryEntrySupervisor do
  @moduledoc false
  use DynamicSupervisor

  alias LocalBroadcast.McamPeerRegistryEntry

  @name __MODULE__

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: @name)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_new_registry_entry(registry, host, ip4_addr) do
    DynamicSupervisor.start_child(@name, {McamPeerRegistryEntry, {registry, host, ip4_addr}})
  end
end
