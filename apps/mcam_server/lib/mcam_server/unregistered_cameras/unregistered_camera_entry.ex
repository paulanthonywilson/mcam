defmodule McamServer.UnregisteredCameras.UnregisteredCameraEntry do
  @moduledoc """
  Process responsible for adding and updating unregistered cameras, timing out the entry
  after 65 seconds.
  """
  use GenServer, restart: :transient

  @timeout 65_000

  def start_link({_registry_name, _ip, _hostname, _local_ip} = args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init({registry, ip, host, local_ip}) do
    {:ok, _pid} = Registry.register(registry, host, registry_value(ip, local_ip))
    # broadcast_updated(registry, host, ip4_addr)

    {:ok, %{registry: registry, host: host, local_ip: local_ip, ip: ip}, @timeout}
  end

  def update_entry(pid, ip, host, local_ip) do
    GenServer.call(pid, {:update_entry, ip, host, local_ip})
  end

  def handle_call(
        {:update_entry, ip, host, local_ip},
        _,
        %{host: host, ip: ip, local_ip: local_ip} = state
      ) do
    {:reply, :ok, state, @timeout}
  end

  def handle_call(
        {:update_entry, ip, host, local_ip},
        _,
        %{registry: registry, host: host} = state
      ) do
    {_, _} = Registry.update_value(registry, host, fn _ -> registry_value(ip, local_ip) end)

    # broadcast_updated(registry, host, ip4_addr)
    {:reply, :ok, %{state | ip: ip, local_ip: local_ip}, @timeout}
  end

  def handle_info(:timeout, %{registry: _registry, host: _host} = state) do
    # broadcast_removed(registry, host)
    {:stop, :normal, state}
  end

  defp registry_value(ip, local_ip) do
    {inspect(ip), local_ip}
  end

  # defp broadcast_updated(registry, host, ip4_addr) do
  #   Events.broadcast(
  #     registry,
  #     {:mcam_peer_registry, :update,
  #      {host, Common.hostname_to_nerves_local_url(host), ip_access_url(ip4_addr)}}
  #   )
  # end

  # defp broadcast_removed(registry, host) do
  #   Events.broadcast(registry, {:mcam_peer_registry, :removed, host})
  # end
end
