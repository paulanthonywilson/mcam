defmodule CamWeb.BinaryWs.DirectImageUrlTest do
  use ExUnit.Case

  alias CamWeb.BinaryWs.DirectImageUrl
  alias Phoenix.LiveView.Socket

  describe "full socket url" do
    test "without ssl and custom port" do
      assert DirectImageUrl.receive_images_websocket_url(
               socket(host: "myhost.com", port: 4000, scheme: "http")
             ) ==
               "ws://myhost.com:4000/direct_image_ws/websocket"
    end

    test "http on 80" do
      assert DirectImageUrl.receive_images_websocket_url(
               socket(host: "myhost.com", port: 80, scheme: "http")
             ) == "ws://myhost.com/direct_image_ws/websocket"
    end

    test "https on custom port" do
      assert DirectImageUrl.receive_images_websocket_url(
               socket(host: "myhost.com", port: 4443, scheme: "https")
             ) == "wss://myhost.com:4443/direct_image_ws/websocket"
    end

    test "https on 443" do
      assert DirectImageUrl.receive_images_websocket_url(
               socket(host: "myhost.com", port: 443, scheme: "https")
             ) == "wss://myhost.com/direct_image_ws/websocket"
    end
  end

  defp socket(uri_atts) do
    %Socket{host_uri: struct!(URI, uri_atts)}
  end
end
