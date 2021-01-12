defmodule McamServerWeb.CameraLiveHelper do
  @moduledoc """
  Helper functions for `McamServerWeb.CameraLive`
  """

  import Phoenix.LiveView.Utils, only: [assign: 3]

  alias McamServer.{Accounts, Cameras}

  def selected_camera(%{"camera_id" => camera_id}, socket) when is_binary(camera_id) do
    selected_camera(%{"camera_id" => String.to_integer(camera_id)}, socket)
  end

  def selected_camera(params, %{assigns: %{all_cameras: own_cameras}}) do
    case do_selected_camera(params, own_cameras) do
      nil -> :no_camera
      camera -> camera
    end
  end

  def do_selected_camera(_, []), do: nil

  def do_selected_camera(%{"camera_id" => camera_id}, [default | _] = cameras) do
    Enum.find(cameras, default, fn %{id: id} -> id == camera_id end)
  end

  def do_selected_camera(_, [first | _]), do: first

  def selected_guest_camera(%{"camera_id" => camera_id}, socket) when is_binary(camera_id) do
    selected_guest_camera(%{"camera_id" => String.to_integer(camera_id)}, socket)
  rescue
    ArgumentError ->
      :no_camera
  end

  def selected_guest_camera(%{"camera_id" => camera_id}, %{
        assigns: %{guest_cameras: guest_cameras}
      }) do
    Enum.find(guest_cameras, :no_camera, fn %{id: id} -> id == camera_id end)
  end

  def selected_guest_camera(_, _), do: :no_camera

  def update_camera(
        %{id: updated_id} = updated_camera,
        %{assigns: %{camera: camera, all_cameras: all_cameras, guest_cameras: guest_cameras}}
      ) do
    camera =
      case camera do
        %{id: ^updated_id} -> updated_camera
        _ -> camera
      end

    all_cameras = do_update_camera(updated_camera, [], all_cameras)
    guest_cameras = do_update_camera(updated_camera, [], guest_cameras)

    {camera, all_cameras, guest_cameras}
  end

  defp do_update_camera(%{id: id} = updated, acc, [%{id: id} | rest]) do
    Enum.reverse([updated | acc], rest)
  end

  defp do_update_camera(updated, acc, [camera | rest]) do
    do_update_camera(updated, [camera | acc], rest)
  end

  defp do_update_camera(_, acc, []), do: Enum.reverse(acc)

  def basic_email_validate(alleged_email) do
    if alleged_email =~ ~r/.+@.+\..+/, do: :ok, else: :bad_email
  end

  def mount_camera(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    all_cameras = Cameras.user_cameras(user)
    guest_cameras = Cameras.guest_cameras(user)
    Cameras.subscribe_to_registrations(user)

    for cam <- all_cameras ++ guest_cameras, do: Cameras.subscribe_to_name_change(cam)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:all_cameras, all_cameras)
     |> assign(:guest_cameras, guest_cameras)}
  end
end
