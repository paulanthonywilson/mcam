defmodule Camera.PicamSettings do
  @moduledoc """
  Set default settings
  """

  use GenServer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, %{}, {:continue, :set}}
  end

  def handle_continue(:set, s) do
    :ok = Configure.subscribe()
    set(:camera_size, Configure.camera_size())
    set(:camera_rotation, Configure.camera_rotation())
    set(:camera_awb_mode, Configure.camera_awb_mode())
    set(:camera_img_effect, Configure.camera_img_effect())
    {:noreply, s}
  end

  def handle_info({:updated_config, setting, value}, s) do
    set(setting, value)
    {:noreply, s}
  end

  defp set(:camera_size, {w, h}), do: Picam.set_size(w, h)
  defp set(:camera_rotation, rotation), do: Picam.set_rotation(rotation)
  defp set(:camera_awb_mode, mode), do: Picam.set_awb_mode(mode)
  defp set(:camera_img_effect, effect), do: Picam.set_img_effect(effect)
  defp set(_, _), do: :ok
end
