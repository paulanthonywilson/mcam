defmodule CamWeb.CameraLive do
  use CamWeb, :live_view

  import ImageServer, only: [receive_images_websocket_url: 0]

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="column">
        <h1>Camera here</h1>
      </div>
    </div>
    <div class="row">
      <div class="column">
        <img id="cam-image" phx-hook="ImageHook"
        data-binary-ws-url="<%= receive_images_websocket_url() %>"></img>
      </div>
    </div>
    """
  end
end
