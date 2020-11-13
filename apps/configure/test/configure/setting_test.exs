defmodule Configure.PersistTest do
  use ExUnit.Case

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
    assert Persist.set(persist_pid, :camera_rotation, 180)

    {:ok, persist_pid} = Persist.start_link({filename, update_topic, nil})
    assert Persist.get(persist_pid, :camera_rotation) == 180
  end

  # test "overrides ssid and secret", %{filename: filename} do
  #   Settings.set(filename, {"bobby", "clitheroe"})

  #   assert Keyword.equal?(
  #            [key_mgmt: :"WPA-PSK", psk: "clitheroe", ssid: "bobby"],
  #            Settings.read_settings(filename)
  #          )
  # end

  # @tag capture_log: true
  # test "uses defaults if file has weird things in it", %{filename: filename} do
  #   File.write(filename, :erlang.term_to_binary([1, 2, 3]))

  #   assert [key_mgmt: :"WPA-PSK", psk: "secret", ssid: "myssid"] ==
  #            Settings.read_settings(filename)
  # end

  # @tag capture_log: true
  # test "uses defaults if file is corrupt", %{filename: filename} do
  #   File.write(filename, "Liam Fox")

  #   assert [key_mgmt: :"WPA-PSK", psk: "secret", ssid: "myssid"] ==
  #            Settings.read_settings(filename)
  # end
end
