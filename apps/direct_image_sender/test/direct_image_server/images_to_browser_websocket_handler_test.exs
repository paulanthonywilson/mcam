defmodule DirectImageSender.ImagesToBrowserWebsocketHandlerTest do
  use ExUnit.Case

  alias DirectImageSender.ImagesToBrowserWebsocketHandler

  test "sending an image" do
    assert {:reply, {:binary, <<0xFF, 0xD8>> <> _}, %{}} =
             ImagesToBrowserWebsocketHandler.websocket_info(:send_image, %{})
  end
end
