defmodule ServerComms.Ws.WebsocketHandler do
  @behaviour :websocket_client_handler

  def init(arg, _connection_state) do
    {:ok, Enum.into(arg, %{})}
  end

  def websocket_handle(message, connection_state, state) do
    IO.inspect({message, connection_state, state}, label: :websocket_handle)
    {:ok, state}
  end

  def websocket_info(message, connection_state, state) do
    IO.inspect({message, connection_state, state}, label: :websocket_handle)
    {:ok, state}
  end

  def websocket_terminate(message, connection_state, %{parent: parent} = state) do
    IO.inspect({message, connection_state, state}, label: :websocket_terminate)
    send(parent, :websocket_terminated)
    :ok
  end
end
