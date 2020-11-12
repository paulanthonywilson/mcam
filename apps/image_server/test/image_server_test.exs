defmodule ImageServerTest do
  use ExUnit.Case

  test "receive_images_websocket_url" do
    assert ImageServer.receive_images_websocket_url() =~ ".local:5000/raw_ws/images_receive"
  end
end
