defmodule CamWeb.CameraSettingsComponent do
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

  defp rotation_options, do: @rotation_options
  defp img_effect_options, do: @img_effect_options
end
