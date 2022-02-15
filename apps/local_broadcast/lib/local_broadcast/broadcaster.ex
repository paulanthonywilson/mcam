defmodule LocalBroadcast.Broadcaster do
  @moduledoc """
  Broadcasts the presence of this MCAM on the local network as
  a UDP multicast every 15 seconds. Also listens for such broadcasts and
  records them in the `LocalBroadcast.McamPeerRegisterEntry`.


  There seems to be an occasional issue with the socket not receiving messages, probably connected with the
  timings of the `wlan0` interface coming up. Could probably address with with subscriptions to `VintageNet`
  or something but in my experience this is too much of a faff.

  Instead we use `Common.Tick` to restart if no message has been received within 35 seconds.
  There should be messages as the UDP is set to loop, meaning our outgoing messages will also be received if the interface is up.

  See `LocalBroadcast.BroadcasterSupervisor` for how it's set up
  """
  use GenServer

  alias Common.Tick
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

  keys = [:socket]
  @enforce_keys keys
  defstruct keys
  @type t :: %__MODULE__{socket: :inet.socket()}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {}, opts)
  end

  def init(_) do
    udp_options = [
      :binary,
      active: @active_count,
      add_membership: {@ip, @local_interface},
      multicast_if: @local_interface,
      multicast_loop: true,
      multicast_ttl: 10,
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

  def handle_info({:udp, _, source_ip, _port, "mcam:" <> host}, state) do
    Tick.tick(:local_broadcast_peers_tick)

    if host != Common.hostname() do
      McamPeerRegistry.record_peer(McamPeerRegistry, host, source_ip)
    end

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug(fn -> "Unexpected message to #{__MODULE__}: #{inspect(msg)}" end)
    {:noreply, state}
  end
end
