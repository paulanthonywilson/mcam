defmodule CamWeb.CameraSettingSelectComponent do
  @moduledoc """
  Label and select box for a camera setting, such as
  exposure mode.
  """

  use CamWeb, :live_component

  def render(assigns) do
    ~L"""
    <form phx-change="change-<%= @setting %>"
          phx-target="<%=@target%>"
          class="camera-settings"
          phx-auto-recover="ignore-settings-recover">
    <label for="<%= @setting %>"><%= @label %></label>
    <select name="<%= @setting %>">
      <%= options_for_select(@options, @current) %>
    </select>
    </form>
    """
  end
end
