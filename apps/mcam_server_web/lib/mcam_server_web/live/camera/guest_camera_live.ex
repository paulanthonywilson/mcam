defmodule McamServerWeb.GuestCameraLive do
  @moduledoc """
  For guest cameras
  """
  use McamServerWeb, :live_view

  import McamServerWeb.CameraLiveHelper, only: [mount_camera: 3, selected_guest_camera: 2]

  def mount(params, session, socket) do
    mount_camera(params, session, socket)
  end

  def handle_params(params, _, socket) do
    camera = selected_guest_camera(params, socket)

    {:noreply, assign(socket, camera: camera)}
  end

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="column column-70">
            <%= live_component @socket, McamServerWeb.CameraComponent,  camera: @camera, title_prefix: "Guest: " %>
      </div>
      <div class="column-30 camera-side">
        <div class="row">
          <div class="column">
            <%= live_component @socket, McamServerWeb.AllCamerasComponent, all_cameras: @all_cameras, camera: @camera %>
          </div>
        </div>
        <div class="row">
          <div class="column">
            <%= live_component @socket, McamServerWeb.GuestCamerasComponenent, guest_cameras: @guest_cameras, camera: @camera %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
