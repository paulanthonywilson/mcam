defmodule McamServerWeb.CameraLiveHelper do
  @moduledoc """
  Helper functions for `McamServerWeb.CameraLive`
  """

  def selected_camera(_, []), do: nil

  def selected_camera(%{"camera_id" => camera_id}, cameras) when is_binary(camera_id) do
    selected_camera(%{"camera_id" => String.to_integer(camera_id)}, cameras)
  end

  def selected_camera(%{"camera_id" => camera_id}, [default | _] = cameras) do
    Enum.find(cameras, default, fn %{id: id} -> id == camera_id end)
  end

  def selected_camera(_, [first | _]), do: first

  def update_camera(
        %{id: updated_id} = updated_camera,
        %{assigns: %{camera: camera, all_cameras: all_cameras}}
      ) do
    camera =
      case camera do
        %{id: ^updated_id} -> updated_camera
        _ -> camera
      end

    all_cameras = do_update_camera(updated_camera, [], all_cameras)

    {camera, all_cameras}
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
end
