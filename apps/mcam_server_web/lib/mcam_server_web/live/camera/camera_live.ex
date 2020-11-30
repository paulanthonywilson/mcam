defmodule McamServerWeb.CameraLive do
  @moduledoc """
  The main page. See the cameras. Live the life.
  """
  use McamServerWeb, :live_view

  alias McamServer.{Accounts, Cameras}

  import McamServerWeb.CameraLiveHelper, only: [selected_camera: 2]

  def mount(params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    all_cameras = Cameras.user_cameras(user)
    camera = selected_camera(params, all_cameras)
    {:ok, assign(socket, user: user, all_cameras: all_cameras, camera: camera)}
  end

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="column column-8 0">
            <%= live_component @socket, McamServerWeb.CameraComponent,  camera: @camera %>
      </div>
      <div class="column">
        <div class="row">
          <div class="column">
            <%= live_component @socket, McamServerWeb.AllCamerasComponent, all_cameras: @all_cameras, camera: @camera %>
          </div>
        </div>
      </div>

    </div>
    """
  end
end
