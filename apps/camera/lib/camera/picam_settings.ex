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

  def set(:camera_size, {w, h}), do: Picam.set_size(w, h)
  def set(:camera_rotation, rotation), do: Picam.set_rotation(rotation)
  def set(:camera_awb_mode, mode), do: Picam.set_awb_mode(mode)
  def set(:camera_img_effect, effect), do: Picam.set_img_effect(effect)
  def set(:camera_exposure_mode, mode), do: Picam.set_exposure_mode(mode)
  def set(_, _), do: :ok

  def set_all do
    for {k, v} <- Configure.all_settings() do
      set(k, v)
    end
  end
end
