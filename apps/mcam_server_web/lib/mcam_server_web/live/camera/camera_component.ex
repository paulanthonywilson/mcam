defmodule McamServerWeb.CameraComponent do
  use McamServerWeb, :live_component

  def render(%{camera: nil} = assigns) do
    ~L"""
    <h2>No camera</h2>
    <p>Instructions for setting up cameras go here.</p>
    """
  end

  def render(assigns) do
    ~L"""
    <h2><%= @camera.board_id %> </h2>
    <img id="cam-image" phx-hook="ImageHook" data-binary-ws-url="<%= receive_images_websocket_url() %>"></img>
    """
  end

  defp receive_images_websocket_url do
    "ws://localhost:4500/raw_ws/images_receive"
  end
end
