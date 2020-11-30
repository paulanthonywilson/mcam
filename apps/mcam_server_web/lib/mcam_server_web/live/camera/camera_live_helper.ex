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
end
