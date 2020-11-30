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
end
