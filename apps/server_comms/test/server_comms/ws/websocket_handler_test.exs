defmodule ServerComms.Ws.WebsocketHandlerTest do
  use ExUnit.Case

  alias ServerComms.Ws.WebsocketHandler

  test "init sets the parent in the state" do
    assert {:ok, %{parent: self()}} == WebsocketHandler.init([parent: self()], %{})
    assert_received :send_next_frame
  end

  test "sets the refreshed token if received down the websocket" do
    token_message = :erlang.term_to_binary({:token_refresh, "this is a new token"})
    assert {:ok, _} = WebsocketHandler.websocket_handle({:binary, token_message}, %{}, %{})
    assert_receive {:fake_setting_set, :registration_token, "this is a new token"}
  end

  test "sends an image on :send_next_frame message" do
    assert {:reply, {:binary, image}, _} =
             WebsocketHandler.websocket_info(:send_next_frame, %{}, %{})

    # jpeg from the fake camera
    assert <<0xFF, 0xD8, 0xFF>> <> _ = image
  end

  test "sends an image on receipt of an ack from the server" do
    assert {:ok, _} = WebsocketHandler.websocket_handle({:binary, "\n"}, %{}, %{})
    assert_receive :send_next_frame
  end
end
