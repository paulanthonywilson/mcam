defmodule McamServerWeb.CameraLiveHelperTest do
  use McamServerWeb.ConnCase

  import McamServer.AccountsFixtures
  import McamServer.CamerasFixtures

  alias McamServerWeb.CameraLiveHelper

  describe "select camera" do
    setup do
      password = "veryslowredfox"
      user = user_fixture(%{password: password})
      cameras = for _i <- 1..5, do: user_camera_fixture(user, password)
      {:ok, user: user, password: password, cameras: cameras}
    end

    test "when in params and list", %{cameras: cameras} do
      [_, cam2 | _] = cameras

      assert CameraLiveHelper.selected_camera(%{"camera_id" => cam2.id}, cameras) == cam2
    end

    test "param is a string", %{cameras: cameras} do
      [_, cam2 | _] = cameras

      assert CameraLiveHelper.selected_camera(%{"camera_id" => to_string(cam2.id)}, cameras) ==
               cam2
    end

    test "params is wrong, but list is not empty", %{cameras: cameras} do
      [first | _] = cameras
      assert CameraLiveHelper.selected_camera(%{"camera_id" => -1}, cameras) == first
    end

    test "no camera_id in params", %{cameras: cameras} do
      [first | _] = cameras
      assert CameraLiveHelper.selected_camera(%{}, cameras) == first
    end

    test "no camera id in params and empty params" do
      assert CameraLiveHelper.selected_camera(%{}, []) == nil
    end

    test "camera id in params but empty params" do
      assert CameraLiveHelper.selected_camera(%{"camera_id" => 12}, []) == nil
    end
  end

  describe "update camera" do
    setup do
      [camera | _] = all_cameras = for i <- 1..5, do: %{id: i, name: "Camera #{i}"}
      {:ok, socket: %{assigns: %{camera: camera, all_cameras: all_cameras}}}
    end

    test "when camera is current, return replacment as current", %{socket: socket} do
      assert {%{id: 1, name: "bobby"}, _} =
               CameraLiveHelper.update_camera(%{id: 1, name: "bobby"}, socket)
    end

    test "when camera is not current, do not replace", %{socket: socket} do
      assert {%{id: 1, name: "Camera 1"}, _} =
               CameraLiveHelper.update_camera(%{id: 2, name: "bobby"}, socket)
    end

    test "updates camera in all cameras", %{socket: socket} do
      assert {_, [%{id: 1, name: "bobby"} | _]} =
               CameraLiveHelper.update_camera(%{id: 1, name: "bobby"}, socket)

      assert {_, [_, %{id: 2, name: "mavis"} | _]} =
               CameraLiveHelper.update_camera(%{id: 2, name: "mavis"}, socket)
    end

    test "no change when not in list", %{
      socket: %{assigns: %{camera: camera, all_cameras: all_cameras}} = socket
    } do
      assert {^camera, ^all_cameras} =
               CameraLiveHelper.update_camera(%{id: 11, name: "dunno"}, socket)
    end
  end
end
