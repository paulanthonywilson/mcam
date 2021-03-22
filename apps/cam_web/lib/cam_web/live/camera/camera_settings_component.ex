defmodule CamWeb.CameraSettingsComponent do
  @moduledoc """
  Live view component for fiddling with the camera settings.
  """
  use CamWeb, :live_component

  alias CamWeb.CameraSettingSelectComponent

  @rotation_options [0, 90, 180, 270]
  @img_effect_options [:none | Enum.sort(~w(
    negative
    solarise
    sketch
    denoise
    emboss
    oilpaint
    hatch
    gpen
    pastel
    watercolor
    film
    blur
    saturation
    colorswap
    washedout
    posterise
    colorpoint
    colorbalance
    cartoon)a)]

  @exposure_modes [:auto | Enum.sort(~w(
      night
      backlight
      spotlight
      sports
      snow
      beach
      verylong
      fixedfps
      antishake
      fireworks
    )a)]

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
      CameraSettingSelectComponent,
      label: "Rotation",
      options: rotation_options(),
      setting: "camera-rotation",
      current: @camera_rotation,
      target: @myself %>

    <%= live_component @socket,
      CameraSettingSelectComponent,
      label: "Image Effect",
      options: img_effect_options(),
      current: @camera_img_effect,
      setting: "img-effect",
      target: @myself %>

    <%= live_component @socket,
      CameraSettingSelectComponent,
      label: "Exposure mode",
      options: exposure_modes(),
      current: @camera_exposure_mode,
      setting: "exposure-mode",
      target: @myself %>
    """
  end

  def handle_event("change-camera-rotation", %{"camera-rotation" => rotation}, socket) do
    Configure.set_camera_rotation(String.to_integer(rotation))
    {:noreply, socket}
  end

  def handle_event("change-img-effect", %{"img-effect" => effect}, socket) do
    Configure.set_camera_img_effect(String.to_existing_atom(effect))
    {:noreply, socket}
  end

  def handle_event("change-exposure-mode", %{"exposure-mode" => mode}, socket) do
    Configure.set_camera_exposure_mode(String.to_existing_atom(mode))
    {:noreply, socket}
  end

  def handle_event("ignore-settings-recover", _params, socket) do
    {:noreply, socket}
  end

  defp rotation_options, do: @rotation_options
  defp img_effect_options, do: @img_effect_options
  defp exposure_modes, do: @exposure_modes
end
