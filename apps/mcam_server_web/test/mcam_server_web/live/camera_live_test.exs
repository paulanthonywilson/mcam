defmodule McamServerWeb.CameraLiveTest do
  use McamServerWeb.ConnCase

  import McamServer.{AccountsFixtures, CamerasFixtures}

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture()

    {:ok, conn: log_in_user(conn, user), user: user}
  end

  describe "index (default route)" do
    test "when there is a camera", %{user: user, conn: conn} do
      camera = user_camera_fixture(user)
      {:ok, _view, html} = live(conn, Routes.camera_path(conn, :index))

      assert html =~ "<h2>" <> camera.name
    end

    test "when there is no camera", %{conn: conn} do
      {:ok, _view, html} = live(conn, Routes.camera_path(conn, :index))

      assert html =~ ~r/no camera/i
    end
  end

  describe "show" do
    test "a particular camera", %{user: user, conn: conn} do
      camera1 = user_camera_fixture(user)
      camera2 = user_camera_fixture(user)

      {:ok, _view, html} = live(conn, Routes.camera_path(conn, :show, camera1.id))
      assert html =~ "<h2>" <> camera1.name

      {:ok, _view, html} = live(conn, Routes.camera_path(conn, :show, camera2.id))
      assert html =~ "<h2>" <> camera2.name
    end
  end

  describe "updating camera name" do
    setup %{user: user} do
      camera = user_camera_fixture(user)

      {:ok, camera: camera}
    end

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
