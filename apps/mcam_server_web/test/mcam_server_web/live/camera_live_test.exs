defmodule McamServerWeb.CameraLiveTest do
  use McamServerWeb.ConnCase

  import McamServer.{AccountsFixtures, CamerasFixtures}

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture()

    camera = user_camera_fixture(user)

    {:ok, camera: camera, conn: log_in_user(conn, user), user: user}
  end

  describe "updating camera name" do
    test "successfully updates and push patches to the return camera id", %{
      camera: %{id: camera_id},
      conn: conn,
      user: user
    } do
      return_camera = user_camera_fixture(user)
      {:ok, view, _html} = live(conn, Routes.camera_path(conn, :edit, camera_id, return_camera))

      render_submit(view, :"update-camera-name", %{"camera-name": "mavis"})
      assert_patched(view, Routes.camera_path(conn, :show, return_camera))

      assert_received {:camera_name_change, %{id: ^camera_id, name: "mavis"}}
    end

    test "a guest cannot edit camera's name", %{camera: camera = %{id: camera_id}, conn: conn} do
      guest = user_fixture()
      add_guest(camera, guest)

      conn = log_in_user(conn, guest)
      %{id: return_camera_id} = user_camera_fixture(guest)

      {:ok, view, _html} =
        live(conn, Routes.camera_path(conn, :edit, camera_id, return_camera_id))

      render_submit(view, :"update-camera-name", %{"camera-name": "mavis"})
      assert_patched(view, Routes.camera_path(conn, :show, return_camera_id))

      refute_received {:camera_name_change, %{id: ^camera_id, name: "mavis"}}

      # Defaults to editing the user's only camera. Confusing UX? Only if someone is messing with the url bar
      assert_received {:camera_name_change, %{id: ^return_camera_id, name: "mavis"}}
    end
  end
end
