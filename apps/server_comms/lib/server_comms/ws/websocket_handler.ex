defmodule ServerComms.Ws.WebsocketHandler do
  @moduledoc """
  Communicates with the server, primarily sending camera images up to form the MPEG stream.

  Uses the traditional Jermy Ong Websocket client but forked [here](https://github.com/paulanthonywilson/websocket_client)
  as some of the Erlang is deprecated.

  Also deals with image refresh; has the potential for dealing with other demands
  such as changing the camera settings.

  """

  @behaviour :websocket_client_handler

  alias Common.Tick

  require Logger

  defstruct parent: nil, next_image_time: 0

  @type t :: %__MODULE__{parent: pid(), next_image_time: integer()}

  # Limit sending to every milliseconds to save bandwidth in case of fast
  # connection. 50 milliseconds is 20fps
  @send_every_millis 50

  def init(args, _connection_state) do
    send(self(), :send_next_frame)
    parent = Keyword.fetch!(args, :parent)
    {:ok, %__MODULE__{parent: parent}}
  end

  def websocket_handle({:binary, "\n"}, _, %{next_image_time: next_image_time} = state) do
    schedule_next_send(next_image_time)
    {:ok, state}
  end

  def websocket_handle({:binary, <<131>> <> _ = message}, _, state) do
    message
    |> :erlang.binary_to_term()
    |> handle_message()

    {:ok, state}
  end

  def websocket_handle(message, _, state) do
    Logger.info(fn -> "Unexpected websocket_handle message: #{inspect(message)}" end)
    {:ok, state}
  end

  def websocket_info(:send_next_frame, _, state) do
    Tick.tick(:server_comms_send_image_tick)

    {:reply, {:binary, Camera.next_frame()},
     %{state | next_image_time: System.monotonic_time(:millisecond) + @send_every_millis}}
  end

  def websocket_info(message, _, state) do
    Logger.warn("Unexpected websocket_info mesage: #{inspect(message)}")
    {:ok, state}
  end

  def websocket_terminate(_, _connection_state, %{parent: parent}) do
    send(parent, :websocket_terminated)
    :ok
  end

  defp handle_message({:token_refresh, token}) do
    Configure.set_registration_token(token)
  end

  defp handle_message(unexpected) do
    Logger.info(fn -> "Unexpected binary message: #{inspect(unexpected)}" end)
  end

  defp schedule_next_send(next_image_time) do
    delay = max(0, next_image_time - System.monotonic_time(:millisecond))
    Process.send_after(self(), :send_next_frame, delay)
  end
end
