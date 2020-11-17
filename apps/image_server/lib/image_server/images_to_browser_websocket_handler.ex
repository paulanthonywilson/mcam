defmodule ImageServer.ImagesToBrowserWebsocketHandler do
  @moduledoc """
  Listens for images being broadcast for a particular camera, and pushes down the websocket.
  """
  require Logger

  def init(%{bindings: bindings} = req, _opts) do
    Logger.debug(fn -> "connected: #{inspect(bindings)}" end)
    {:cowboy_websocket, req, %{}}
  end

  def websocket_init(state) do
    Logger.debug(fn -> "init: #{inspect(state)}" end)
    send(self(), :send_image)
    {:ok, state}
  end

  def websocket_handle(data, state) do
    Logger.warn(fn -> "Unexpected websocket_handle: #{inspect({data, state})}" end)
    {:ok, state}
  end

  def websocket_info(:send_image, state) do
    image = Camera.next_frame()
    Process.send_after(self(), :send_image, 50)
    {:reply, {:binary, image}, state}
  end

  def websocket_info(info, state) do
    Logger.warn(fn -> "Unexpected websocket_info: #{inspect({info, state})}" end)
    {:ok, state}
  end
end
