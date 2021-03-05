defmodule LocalBroadcast.McamPeerRegistryEntry do
  @moduledoc """
  Process responsible for adding and updating an entry to the peer registry. The process part is about
  enabling expiry through timeout.
  """
  use GenServer, restart: :transient

  alias LocalBroadcast.Events

  @local_web_port Common.local_web_port()

  @timeout 50_000

  def start_link({_registry_name, _hostname, _ip4_addr} = args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init({registry, host, ip4_addr}) do
    {:ok, _pid} = Registry.register(registry, host, registry_value(host, ip4_addr))
    broadcast_updated(registry, host, ip4_addr)

    {:ok, %{registry: registry, host: host, ip4_addr: ip4_addr}, @timeout}
  end

  def update_entry(pid, host, ip4_addr) do
    GenServer.call(pid, {:update_entry, host, ip4_addr})
  end

  def handle_call({:update_entry, host, ip4_addr}, _, %{host: host, ip4_addr: ip4_addr} = state) do
    {:reply, :ok, state, @timeout}
  end

  def handle_call({:update_entry, host, ip4_addr}, _, %{registry: registry} = state) do
    {_, _} = Registry.update_value(registry, host, fn _ -> registry_value(host, ip4_addr) end)

    broadcast_updated(registry, host, ip4_addr)
    {:reply, :ok, %{state | ip4_addr: ip4_addr}, @timeout}
  end

  def handle_info(:timeout, %{registry: registry, host: host} = state) do
    broadcast_removed(registry, host)
    {:stop, :normal, state}
  end

  defp registry_value(host, ip4_addr) do
    host_url = Common.hostname_to_nerves_local_url(host)
    ip4_url = ip_access_url(ip4_addr)
    {host, host_url, ip4_url}
  end

  defp ip_access_url({i1, i2, i3, i4}) do
    "http://#{i1}.#{i2}.#{i3}.#{i4}:#{@local_web_port}"
  end

  defp broadcast_updated(registry, host, ip4_addr) do
    Events.broadcast(
      registry,
      {:mcam_peer_registry, :update,
       {host, Common.hostname_to_nerves_local_url(host), ip_access_url(ip4_addr)}}
    )
  end

  defp broadcast_removed(registry, host) do
    Events.broadcast(registry, {:mcam_peer_registry, :removed, host})
  end
end
