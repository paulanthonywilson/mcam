defmodule CamWeb.CameraLive do
  @moduledoc """
  Main LiveViw page. Shows the camera stream as well
  as settings and registration.
  """
  use CamWeb, :live_view

  alias CamWeb.{
    CameraSettingsComponent,
    PeersComponent,
    RegistrationComponent,
    ServerConnectionComponent
  }

  import CamWeb.BinaryWs.DirectImageUrl, only: [receive_images_websocket_url: 1]

  def mount(_params, _session, socket) do
    Configure.subscribe()
    settings = Enum.into(Configure.all_settings(), [])
    :ok = ServerComms.subscribe()
    :ok = LocalBroadcast.subscribe()

    {:ok,
     assign(socket,
       settings: settings,
       server_connection_status: ServerComms.connection_status(),
       peers: LocalBroadcast.peers()
     )}
  end

  def handle_info({:updated_config, key, value}, socket) do
    settings = update_setting(socket, key, value)
    {:noreply, assign(socket, settings: settings)}
  end

  def handle_info({:server_connection_status_changed, connection_status}, socket) do
    {:noreply, assign(socket, server_connection_status: connection_status)}
  end

  def handle_info({:mcam_peer_registry, :removed, host}, %{assigns: %{peers: peers}} = socket) do
    peers = remove_host_from_peers(peers, host)
    {:noreply, assign(socket, peers: peers)}
  end

  def handle_info(
        {:mcam_peer_registry, :update, {host, _, _} = peer},
        %{assigns: %{peers: peers}} = socket
      ) do
    peers = [peer | remove_host_from_peers(peers, host)]
    {:noreply, assign(socket, peers: peers)}
  end

  defp remove_host_from_peers(peers, host) do
    Enum.reject(peers, fn
      {^host, _, _} -> true
      _ -> false
    end)
  end

  defp update_setting(socket, key, value) do
    socket
    |> Map.get(:assigns)
    |> Map.get(:settings)
    |> Keyword.put(key, value)
  end

  def render(assigns) do
    ~L"""
    <%= live_component @socket, ServerConnectionComponent, server_connection_status: @server_connection_status %>
    <div class="row">
      <p class="column">Local network acccess url: <a href="<%= Common.hostname_to_nerves_local_url() %>"><%= Common.hostname_to_nerves_local_url() %> </a></p>
    </div>
    <div class="row">
      <div class="column-75">
        <img id="cam-image" phx-hook="ImageHook"
        data-binary-ws-url="<%= receive_images_websocket_url(@socket) %>"></img>
      </div>
      <div class="column-20 camera-side">
        <div class="row">
          <div class="column">
            <%= live_component @socket, CameraSettingsComponent, [{:id, :camera_settings} | @settings] %>
          </div>
        </div>
        <div class="row">
          <div class="column">
            <%= live_component @socket, RegistrationComponent, [{:id, :camera_registration} | @settings] %>
          </div>
        </div>
      </div>
    </div>
    <div class="row"">
      <div class="column">
          <%= live_component @socket, PeersComponent, peers: @peers %>
       </div>
    </div>
    """
  end
end
