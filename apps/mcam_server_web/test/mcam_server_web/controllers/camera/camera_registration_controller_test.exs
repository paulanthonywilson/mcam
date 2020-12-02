defmodule McamServerWeb.Camera.CameraRegistrationControllerTest do
  use McamServerWeb.ConnCase, async: true
  import McamServer.AccountsFixtures

  alias McamServer.Cameras

  setup do
    %{user: user_fixture(email: "bob@mavis.com", password: "marvinmarvinmarvin")}
  end

  test "successfully registering a camera", %{conn: conn, user: %{id: user_id}} do
    conn =
      post(conn, Routes.camera_registration_path(conn, :create), %{
        email: "bob@mavis.com",
        password: "marvinmarvinmarvin",
        board_id: "c3p0"
      })

    assert response = json_response(conn, 200)

    assert {:ok, %{board_id: "c3p0", owner_id: ^user_id}} = Cameras.from_token(response, :camera)
  end

  test "invalid user details", %{conn: conn} do
    conn =
      post(conn, Routes.camera_registration_path(conn, :create), %{
        email: "bob@mavis.com",
        password: "nope",
        board_id: "c3p0"
      })

    assert json_response(conn, 401)
  end

  test "400 response without the required params", %{conn: conn} do
    assert conn
           |> post(Routes.camera_registration_path(conn, :create), %{})
           |> json_response(400)
  end
end
