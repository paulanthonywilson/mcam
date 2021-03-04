defmodule LocalBroadcast.Broadcaster do
  @moduledoc """
  Broadcasts the presence of this MCAM on the local network as
  a UDP multicast every 15 seconds. Also listens for such broadcasts and
  records them in the `LocalBroadcast.McamPeerRegisterEntry`
  """
  use GenServer

  alias LocalBroadcast.McamPeerRegistry

  require Logger

  @ip {224, 1, 1, 1}
  @port (case Mix.env() do
           :test ->
             49_998

           _ ->
             49_999
         end)
  @broadcast_inverval 15_000

  @local_interface {0, 0, 0, 0}

  @active_count 10

  @message_prefix "mcam:"

  defstruct socket: nil

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {}, opts)
  end

  def init(_) do
    udp_options = [
      :binary,
      active: @active_count,
      add_membership: {@ip, @local_interface},
      multicast_if: @local_interface,
      multicast_loop: false,
      multicast_ttl: 1,
      reuseaddr: true
    ]

    {:ok, socket} = :gen_udp.open(@port, udp_options)
    send(self(), :broadcast)
    {:ok, %__MODULE__{socket: socket}}
  end

  def handle_info(:broadcast, %{socket: socket} = state) do
    :gen_udp.send(socket, @ip, @port, "#{@message_prefix}#{Common.hostname()}")
    Process.send_after(self(), :broadcast, @broadcast_inverval)
    {:noreply, state}
  end

  def handle_info({:udp_passive, _port}, state) do
    Process.send_after(self(), :reactivate, 1_000)
    {:noreply, state}
  end

  def handle_info(:reactivate, %{socket: socket} = state) do
    :inet.setopts(socket, active: @active_count)
    {:noreply, state}
  end

  def handle_info({:udp, _, source_ip, _port, host}, state) do
    McamPeerRegistry.record_peer(McamPeerRegistry, host, source_ip)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug(fn -> "Unexpected message to #{__MODULE__}: #{inspect(msg)}" end)
    {:noreply, state}
  end
end
