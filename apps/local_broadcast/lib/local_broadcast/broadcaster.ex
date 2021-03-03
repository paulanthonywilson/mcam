defmodule LocalBroadcast.Broadcaster do
  use GenServer

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

  def handle_info(msg, state) do
    Logger.info("Broadcast received: #{inspect(msg)}")
    {:noreply, state}
  end
end
