defmodule McamServer.UnregisteredCamerasTest do
  use ExUnit.Case, async: true

  alias McamServer.UnregisteredCameras

  setup do
    registry_name = self() |> inspect() |> String.to_atom()
    {:ok, _pid} = Registry.start_link(keys: :unique, name: registry_name)
    {:ok, unregistered_cameras} = UnregisteredCameras.start_link(registry_name: registry_name)
    {:ok, unregistered_cameras: unregistered_cameras, registry_name: registry_name}
  end

  test "adding and retrieving cameras", %{unregistered_cameras: unregistered_cameras} do
    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    assert [{"nerves-b4lx", "10.20.0.21"}] ==
             UnregisteredCameras.cameras_from_ip(unregistered_cameras, {83, 52, 11, 214})
  end

  test "multiple registrations from remote ip", %{unregistered_cameras: unregistered_cameras} do
    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4ld", "10.20.0.22"}
      )

    assert [{"nerves-b4ld", "10.20.0.22"}, {"nerves-b4lx", "10.20.0.21"}] ==
             UnregisteredCameras.cameras_from_ip(unregistered_cameras, {83, 52, 11, 214})
  end

  test "updating a camera", %{unregistered_cameras: unregistered_cameras} do
    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.22"}
      )

    assert [{"nerves-b4lx", "10.20.0.22"}] ==
             UnregisteredCameras.cameras_from_ip(unregistered_cameras, {83, 52, 11, 214})
  end

  test "cameras from ip only returns cameras from a particular remote ip", %{
    unregistered_cameras: unregistered_cameras
  } do
    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 215}, "nerves-other", "10.20.0.22"}
      )

    assert [{"nerves-b4lx", "10.20.0.21"}] ==
             UnregisteredCameras.cameras_from_ip(unregistered_cameras, {83, 52, 11, 214})
  end

  test "timing out", %{unregistered_cameras: unregistered_cameras, registry_name: registry_name} do
    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    :sys.get_state(unregistered_cameras)

    [{pid, _}] = Registry.lookup(registry_name, "nerves-b4lx")

    send(pid, :timeout)

    assert [] ==
             wait_until_equals([], fn ->
               UnregisteredCameras.cameras_from_ip(unregistered_cameras, {83, 52, 11, 214})
             end)
  end

  test "timeout and update race condition",
       %{unregistered_cameras: unregistered_cameras, registry_name: registry_name} do
    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    :sys.get_state(unregistered_cameras)

    [{pid, _}] = Registry.lookup(registry_name, "nerves-b4lx")

    send(pid, :timeout)

    :ok =
      UnregisteredCameras.record_camera_from_ip(
        unregistered_cameras,
        {{83, 52, 11, 214}, "nerves-b4lx", "10.20.0.21"}
      )

    assert [{"nerves-b4lx", "10.20.0.21"}] ==
             UnregisteredCameras.cameras_from_ip(unregistered_cameras, {83, 52, 11, 214})
  end

  defp wait_until_equals(expected, actual_fn, attempt_count \\ 0)
  defp wait_until_equals(_expected, actual_fn, 100), do: actual_fn.()

  defp wait_until_equals(expected, actual_fn, attempt_count) do
    case actual_fn.() do
      ^expected ->
        expected

      _ ->
        :timer.sleep(1)
        wait_until_equals(expected, actual_fn, attempt_count + 1)
    end
  end
end
