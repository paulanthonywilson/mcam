defmodule CamWeb.CameraLive do
  use CamWeb, :live_view
  alias CamWeb.CameraSettingsComponent

  import ImageServer, only: [receive_images_websocket_url: 0]

  def mount(_params, _session, socket) do
    Configure.subscribe()
    settings = Enum.into(Configure.all_settings(), [])
    {:ok, assign(socket, settings: settings)}
  end

  def handle_info({:updated_config, key, value}, socket) do
    settings =  socket
    |> Map.get(:assigns)
    |> Map.get(:settings)
    |> Keyword.put(key, value)

    {:noreply, assign(socket, settings: settings)}
  end

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="column">
        <h1>Camera here</h1>
      </div>
    </div>
    <div class="row">
      <div class="column-75">
        <img id="cam-image" phx-hook="ImageHook"
        data-binary-ws-url="<%= receive_images_websocket_url() %>"></img>
      </div>
      <div class="column-20">
      <%= live_component @socket, CameraSettingsComponent, [{:id, :camera_settings} | @settings] %>
      </div>
    </div>
    """
  end
end
