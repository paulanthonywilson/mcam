defmodule CamWeb.CameraSettingsComponent do
  @moduledoc """
  Live view component for fiddling with the camera settings.
  """
  use CamWeb, :live_component

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
    <form phx-change="change-camera-rotation" phx-target="<%=@myself%>" class="camera-settings">
    <label for="camera-rotation">Rotation</label>
    <select name="camera-rotation">
      <%= options_for_select(rotation_options(), @camera_rotation) %>
    </select>
    </form>

    <form phx-change="change-img-effect" phx-target="<%=@myself%>" class="camera-settings">
    <label for="camera-img-effect">Image Effect</label>
    <select name="camera-img-effect">
      <%= options_for_select(img_effect_options(), @camera_img_effect) %>
    </select>
    </form>

    <form phx-change="change-exposure-mode" phx-target="<%=@myself%>" class="camera-settings">
    <label for="camera-exposure-mode">Exposure mode</label>
    <select name="camera-exposure-mode">
      <%= options_for_select(exposure_modes(), @camera_exposure_mode) %>
    </select>
    </form>
    """
  end

  def handle_event("change-camera-rotation", %{"camera-rotation" => rotation}, socket) do
    Configure.set_camera_rotation(String.to_integer(rotation))
    {:noreply, socket}
  end

  def handle_event("change-img-effect", %{"camera-img-effect" => effect}, socket) do
    Configure.set_camera_img_effect(String.to_existing_atom(effect))
    {:noreply, socket}
  end

  def handle_event("change-exposure-mode", %{"camera-exposure-mode" => mode}, socket) do
    Configure.set_camera_exposure_mode(String.to_existing_atom(mode))
    {:noreply, socket}
  end

  defp rotation_options, do: @rotation_options
  defp img_effect_options, do: @img_effect_options
  defp exposure_modes, do: @exposure_modes
end
