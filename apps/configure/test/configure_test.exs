defmodule ConfigureTest do
  use ExUnit.Case, async: false

  test "settings" do
    assert {644, 484} = Configure.camera_size()

    Configure.set_camera_rotation(90)

    assert_receive {:fake_setting_set, :camera_rotation, 90}
  end
end
