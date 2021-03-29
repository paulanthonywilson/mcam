defmodule McamServerWeb.GuestCameraLiveTest do
  use McamServerWeb.ConnCase

  import McamServer.{AccountsFixtures, CamerasFixtures}

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    host = user_fixture()
    guest = user_fixture()

    camera = user_camera_fixture(host)
    add_guest(camera, guest)

    {:ok, conn: log_in_user(conn, guest), guest_camera: camera}
  end

  test "can show guest camera", %{guest_camera: guest_camera, conn: conn} do
    {:ok, _view, html} = live(conn, Routes.guest_camera_path(conn, :show, guest_camera.id))

    assert html =~ "<h2>Guest: " <> guest_camera.name
  end
end
