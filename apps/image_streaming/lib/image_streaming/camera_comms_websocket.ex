defmodule ImageStreaming.CameraCommsWebsocket do
  @moduledoc """
  Websocket handler for communication with the cameras.

  See https://ninenines.eu/docs/en/cowboy/2.8/guide/ws_handlers/
  """

  alias McamServer.Cameras

  require Logger

  @acknowledge_image_receipt "\n"

  def init(req = %{bindings: %{token: token}}, opts) do
    case Cameras.from_token(token, :camera) do
      {:ok, %{id: camera_id}} ->
        {:cowboy_websocket, req, Map.put(opts, :camera_id, camera_id)}

      {:error, :invalid} ->
        error_websocket_response(400, req, opts)

      {:error, :expired} ->
        error_websocket_response(401, req, opts)

      {:error, :not_found} ->
        error_websocket_response(404, req, opts)
    end
  end

  defp error_websocket_response(status, req, opts) do
    {:ok, :cowboy_req.reply(status, req), opts}
  end

  def websocket_init(%{camera_id: camera_id} = state) do
    refreshed_token = Cameras.token_for(camera_id, :camera)
    message = :erlang.term_to_binary({:token_refresh, refreshed_token})
    {[binary: message], state}
  end

  def terminate(_reason, _req, %{camera_id: camera_id}) do
    Logger.debug(fn -> "Camera disconnected: #{camera_id}" end)
    Monitoring.camera_disconnected(camera_id)
    :ok
  end

  def terminate(_reason, _req, _state) do
    Logger.warn(fn -> "Disconnection without camera id" end)
    :ok
  end

  def websocket_handle({:binary, image}, state = %{camera_id: camera_id}) do
    Monitoring.image_received(camera_id)
    Cameras.broadcast_image(camera_id, image)
    {:reply, {:binary, @acknowledge_image_receipt}, state}
  end

  def websocket_handle(data, state) do
    Logger.warn(fn -> "Unexpected websocket_handle: #{inspect({data, state})}" end)
    {:ok, state}
  end

  def websocket_info(info, state) do
    Logger.warn(fn -> "Unexpected websocket_info: #{inspect({info, state})}" end)
    {:ok, state}
  end
end
