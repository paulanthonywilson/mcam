defmodule McamServerWeb.AllCamerasComponent do
  @moduledoc """
  Component for listing a user's cameras, and selecting the camera to view.camera
  """
  use McamServerWeb, :live_component

  def render(assigns) do
    ~L"""
    <h2>Your Cameras</h2>
    <ul class="camera-list">
    <%= for cam <- @all_cameras do %>
      <li>
      <%= if cam == @camera do %>
        <%= cam.board_id %>
      <% else %>
        <%= live_redirect cam.board_id, to: Routes.camera_path(@socket, :show, cam.id) %>
      <% end %>
      </li>
    <% end %>
    </ul>
    """
  end
end
