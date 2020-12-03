defmodule ImageStreaming.ImagesToBrowserWebsocket do
  @moduledoc """
  Websocket handler for sending images to the browser

  See https://ninenines.eu/docs/en/cowboy/2.8/guide/ws_handlers/
  """

  alias McamServer.Cameras

  require Logger

  @refresh_token_every 1_000

  def init(req = %{bindings: %{token: token}}, opts) do
    case Cameras.from_token(token, :browser) do
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

  def websocket_init(%{camera_id: camera_id} = state) do
    Process.send_after(self(), :refresh_token, @refresh_token_every)
    Cameras.subscribe_to_camera(camera_id)
    {:ok, state}
  end

  def websocket_info(:refresh_token, %{camera_id: camera_id} = state) do
    Process.send_after(self(), :refresh_token, @refresh_token_every)
    token = Cameras.token_for(camera_id, :browser)
    {:reply, {:text, "token:#{token}"}, state}
  end

  def websocket_info({:camera_image, _camera_id, image}, state) do
    {:reply, {:binary, image}, state}
  end

  defp error_websocket_response(status, req, opts) do
    {:ok, :cowboy_req.reply(status, req), opts}
  end
end
