defmodule ImageStreaming.CameraCommsWebsocketTest do
  use ExUnit.Case

  import McamServer.CamerasFixtures

  alias ImageStreaming.CameraCommsWebsocket
  alias McamServer.Cameras

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(McamServer.Repo)
  end

  describe "initiation" do
    test "camera ok" do
      camera = camera_fixture()
      camera_id = camera.id

      req =
        camera
        |> Cameras.token_for(:camera)
        |> req()

      assert {:cowboy_websocket, ^req, %{camera_id: ^camera_id}} =
               CameraCommsWebsocket.init(req, %{})

      ## No response - ie no news is good news
      refute_receive _
    end

    test "invalid token" do
      assert {:ok, %{has_sent_resp: true}, _} = CameraCommsWebsocket.init(req("blah"), %{})

      assert_receive {_, {:response, 400, _, _}}
    end

    test "expired token" do
      assert {:ok, %{has_sent_resp: true}, _} =
               CameraCommsWebsocket.init(req(expired_token()), %{})

      assert_receive {_, {:response, 401, _, _}}
    end

    test "token for camera that is no longer there" do
      req =
        -1
        |> Cameras.token_for(:camera)
        |> req()

      assert {:ok, %{has_sent_resp: true}, _} = CameraCommsWebsocket.init(req, %{})

      assert_receive {_, {:response, 404, _, _}}
    end
  end

  describe "websocket init" do
    test "sends back a token refresh message" do
      %{id: camera_id} = camera_fixture()
      state = %{camera_id: camera_id}
      assert {[{:binary, message}], ^state} = CameraCommsWebsocket.websocket_init(state)
      assert {:token_refresh, token} = :erlang.binary_to_term(message)

      assert {:ok, %{id: ^camera_id}} = Cameras.from_token(token, :camera)
    end
  end

  describe "receiving image" do
    test "broadcasts the image" do
      %{id: camera_id} = camera_fixture()

      Cameras.subscribe_to_camera(camera_id)
      state = %{camera_id: camera_id}

      image = <<0xFF, 0xD8, 0xFF>> <> "not really an image"

      assert {:reply, {:binary, <<0x0A>>}, ^state} =
               CameraCommsWebsocket.websocket_handle({:binary, image}, state)

      assert_receive {:camera_image, ^camera_id, ^image}
    end
  end

  defp req(token) do
    %{bindings: %{token: token}, pid: self(), streamid: 1}
  end

  defp expired_token do
    secrets = Application.fetch_env!(:mcam_server, :camera_token)
    Plug.Crypto.encrypt(secrets[:secret], secrets[:salt], 1, signed_at: 0)
  end
end
