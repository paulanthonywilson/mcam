defmodule McamServerWeb.CameraLive do
  @moduledoc """
  The main page. See the cameras. Live the life.
  """
  use McamServerWeb, :live_view

  alias McamServer.{Accounts, Cameras}
  alias McamServerWeb.EditItemFormComponent

  import McamServerWeb.CameraLiveHelper, only: [selected_camera: 2, update_camera: 2]

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    all_cameras = Cameras.user_cameras(user)
    for cam <- all_cameras, do: Cameras.subscribe_to_name_change(cam)
    Cameras.subscribe_to_registrations(user)

    {:ok, assign(socket, user: user, all_cameras: all_cameras)}
  end

  def handle_params(params, _, socket) do
    %{assigns: %{all_cameras: all_cameras}} = socket

    camera = selected_camera(params, all_cameras)
    from_camera_id = params["from_camera_id"]
    {:noreply, assign(socket, camera: camera, from_camera_id: from_camera_id)}
  end

  def handle_event("update-camera-name", %{"camera-name" => camera_name}, socket) do
    %{assigns: %{from_camera_id: from_camera_id, camera: camera}} = socket
    Cameras.change_name(camera, camera_name)
    {:noreply, push_patch(socket, to: edit_return_path(socket, from_camera_id))}
  end

  def handle_info({:camera_name_change, updated}, socket) do
    {camera, all_cameras} = update_camera(updated, socket)
    {:noreply, assign(socket, camera: camera, all_cameras: all_cameras)}
  end

  def handle_info({:camera_registration, camera}, socket) do
    %{assigns: %{all_cameras: all_cameras}} = socket
    {:noreply, assign(socket, all_cameras: all_cameras ++ [camera])}
  end

  defp edit_return_path(socket, from_camera_id) do
    Routes.camera_path(socket, :show, from_camera_id)
  end

  def render(assigns) do
    ~L"""
    <%= if @live_action == :edit do %>
      <%= live_modal @socket, EditItemFormComponent, camera: @camera, return_to: edit_return_path(@socket, @from_camera_id)  %>
    <% end %>
    <div class="row">
      <div class="column column-70">
            <%= live_component @socket, McamServerWeb.CameraComponent,  camera: @camera %>
      </div>
      <div class="column-30 camera-side">
        <div class="row">
          <div class="column">
            <%= live_component @socket, McamServerWeb.AllCamerasComponent, all_cameras: @all_cameras, camera: @camera %>
          </div>
        </div>
        <div class="row">
          <div class="column">
            <%= live_component @socket, McamServerWeb.InviteAGuestComponent, camera: @camera, user: @user, id: :invite_guest %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
