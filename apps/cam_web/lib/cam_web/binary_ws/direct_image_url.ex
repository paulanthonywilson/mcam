defmodule CamWeb.BinaryWs.DirectImageUrl do
  @moduledoc """
  Paths to the direct image socket
  """

  @socket_path "/direct_image_ws"

  def socket_path, do: @socket_path

  def receive_images_websocket_url(%{host_uri: host_uri}) do
    do_receive_images_websocket_url(host_uri)
  end

  defp do_receive_images_websocket_url(%{host: host, port: port, scheme: http_scheme}) do
    ws_scheme = ws_scheme_for(http_scheme)

    "#{ws_scheme}://#{host}#{port_url_part(http_scheme, port)}"
    |> Path.join(@socket_path)
    |> Path.join("websocket")
  end

  defp ws_scheme_for("http"), do: "ws"
  defp ws_scheme_for("https"), do: "wss"

  defp port_url_part("http", 80), do: ""
  defp port_url_part("https", 443), do: ""
  defp port_url_part(_, port), do: ":#{port}"
end
