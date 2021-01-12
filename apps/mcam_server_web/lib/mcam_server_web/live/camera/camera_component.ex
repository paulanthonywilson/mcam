defmodule McamServerWeb.CameraComponent do
  @moduledoc """
  Sets up the image for serving camera images in the browser.
  """
  use McamServerWeb, :live_component

  alias McamServer.Cameras

  def render(%{camera: :no_camera} = assigns) do
    ~L"""
    <h2>No camera</h2>
    <p>Instructions for setting up cameras go here.</p>
    """
  end

  def render(assigns) do
    assigns = Map.put_new(assigns, :title_prefix, "")

    ~L"""
    <h2><%= @title_prefix %><%= @camera.name %> </h2>
    <img id="cam-image" phx-hook="ImageHook" src="<%= Routes.static_path(@socket, "/images/placeholder.jpeg")  %>"
         data-binary-ws-url="<%= receive_images_websocket_url() %>"
         data-ws-token="<%= token(@camera) %>" ></img>
    """
  end

  defp receive_images_websocket_url do
    :common
    |> Application.fetch_env!(:server_ws)
    |> Path.join("raw_ws/browser_interface")
  end

  defp token(camera) do
    Cameras.token_for(camera, :browser)
  end
end
