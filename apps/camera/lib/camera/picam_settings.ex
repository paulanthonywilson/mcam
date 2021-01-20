defmodule Camera.PicamSettings do
  @moduledoc """
  Set default settings
  """

  use GenServer

  @name __MODULE__

  @set_all_timeout 90_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, %{}, {:continue, :set}}
  end

  def handle_continue(:set, s) do
    :ok = Configure.subscribe()
    set_all()
    {:noreply, s, @set_all_timeout}
  end

  def handle_info({:updated_config, setting, value}, s) do
    set(setting, value)
    {:noreply, s, @set_all_timeout}
  end

  def handle_info(:timeout, s) do
    set_all()
    {:noreply, s, @set_all_timeout}
  end

  defp set(:camera_size, {w, h}), do: Picam.set_size(w, h)
  defp set(:camera_rotation, rotation), do: Picam.set_rotation(rotation)
  defp set(:camera_awb_mode, mode), do: Picam.set_awb_mode(mode)
  defp set(:camera_img_effect, effect), do: Picam.set_img_effect(effect)
  defp set(:camera_exposure_mode, mode), do: Picam.set_exposure_mode(mode)
  defp set(_, _), do: :ok

  defp set_all do
    set(:camera_size, Configure.camera_size())
    set(:camera_rotation, Configure.camera_rotation())
    set(:camera_awb_mode, Configure.camera_awb_mode())
    set(:camera_img_effect, Configure.camera_img_effect())
    set(:camera_exposure_mode, Configure.camera_exposure_mode())
  end
end
