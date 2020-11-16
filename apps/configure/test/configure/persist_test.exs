defmodule Configure.PersistTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Configure.{Events, Persist}

  setup do
    filename = "#{System.tmp_dir!()}/#{inspect(self())}.txt"
    update_topic = "updated_#{inspect(self())}"

    Events.subscribe(update_topic)

    {:ok, persist_pid} = Persist.start_link({filename, update_topic, nil})

    on_exit(fn ->
      File.rm(filename)
    end)

    {:ok, filename: filename, persist_pid: persist_pid, update_topic: update_topic}
  end

  test "uses default setting", %{persist_pid: persist_pid} do
    assert Persist.get(persist_pid, :camera_rotation) == 0
  end

  test "setting a value", %{persist_pid: persist_pid} do
    assert Persist.set(persist_pid, :camera_rotation, 90)
    assert Persist.get(persist_pid, :camera_rotation) == 90

    assert_receive {:updated_config, :camera_rotation, 90}
  end

  test "setting a value is persisted", %{
    persist_pid: persist_pid,
    update_topic: update_topic,
    filename: filename
  } do
    :ok = Persist.set(persist_pid, :camera_rotation, 180)
    assert Persist.get(persist_pid, :camera_rotation) == 180

    {:ok, persist_pid} = Persist.start_link({filename, update_topic, nil})
    assert Persist.get(persist_pid, :camera_rotation) == 180
  end

  test "a corrrupt file reverts to default settings", %{
    persist_pid: persist_pid,
    update_topic: update_topic,
    filename: filename
  } do
    :ok = Persist.set(persist_pid, :camera_rotation, 180)
    assert Persist.get(persist_pid, :camera_rotation) == 180

    File.write!(filename, "Bobby bobber bob")

    log =
      capture_log(fn ->
        {:ok, persist_pid} = Persist.start_link({filename, update_topic, nil})
        assert Persist.get(persist_pid, :camera_rotation) == 0
      end)

    assert log =~ "Corrupt file"
  end
end
