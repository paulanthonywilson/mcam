defmodule LocalBroadcast.McamPeerRegistry do
  @moduledoc """
  Holds a registry of MCAM peers on the local network, and their local access urls.

  Entries expire after a while. See `LocalBroadcast.McamPeerRegistryEntry`.
  """

  use GenServer

  alias LocalBroadcast.{Events, McamPeerRegistryEntrySupervisor, McamPeerRegistryEntry}

  def start_link(opts) do
    {registry_name, opts} = Keyword.pop!(opts, :registry_name)
    GenServer.start_link(__MODULE__, registry_name, opts)
  end

  def init(registry_name) do
    {:ok, %{registry: registry_name}}
  end

  @doc """
  Receive notifications on change to the registry
  """
  def subscribe(server) do
    registry = GenServer.call(server, :get_registry)
    Events.subscribe(registry)
  end

  @doc """
  Record a peer by hostname and IP4 address. Updates the IP4 address if already recorded.
  """
  @spec record_peer(atom() | pid(), String.t(), :inet.ip4_address()) :: :ok
  def record_peer(server, host, ip) do
    GenServer.cast(server, {:record_peer, host, ip})
  end

  @doc """
  Lists the web access urls of the peers as two-string tuples, the first being
  via MDNS hostname and the other by IP address
  """
  @spec peers(atom() | pid()) :: list({String.t(), String.t()})
  def peers(server) do
    GenServer.call(server, :peers)
  end

  def handle_cast({:record_peer, host, ip}, %{registry: registry} = state) do
    case Registry.lookup(registry, host) do
      [] ->
        {:ok, _pid} =
          McamPeerRegistryEntrySupervisor.create_new_registry_entry(registry, host, ip)

      [{pid, _value}] ->
        :ok = McamPeerRegistryEntry.update_entry(pid, host, ip)
    end

    {:noreply, state}
  end

  def handle_call(:peers, _, %{registry: registry} = state) do
    result =
      registry
      |> Registry.select([{{:_, :_, :"$3"}, [], [{{:"$3"}}]}])
      |> Enum.map(fn {x} -> x end)
      |> Enum.sort()

    {:reply, result, state}
  end

  def handle_call(:get_registry, _, %{registry: registry} = state) do
    {:reply, registry, state}
  end
end
