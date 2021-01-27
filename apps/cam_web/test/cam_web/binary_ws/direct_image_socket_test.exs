defmodule CamWeb.BinaryWs.DirectImageSocketTest do
  use ExUnit.Case
  alias CamWeb.BinaryWs.DirectImageSocket

  test "sending an image" do
    assert {:push, {:binary, <<0xFF, 0xD8>> <> _}, %{}} =
             DirectImageSocket.handle_info(:send_image, %{})
  end
end
