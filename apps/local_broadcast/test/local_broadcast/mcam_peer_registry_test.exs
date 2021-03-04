defmodule LocalBroadcast.McamPeerRegistryTest do
  use ExUnit.Case, async: true

  alias LocalBroadcast.McamPeerRegistry

  setup do
    registry_name = self() |> inspect() |> String.to_atom()
    {:ok, _pid} = Registry.start_link(keys: :unique, name: registry_name)
    {:ok, peer_registry} = McamPeerRegistry.start_link(registry_name: registry_name)
    {:ok, peer_registry: peer_registry, registry_name: registry_name}
  end

  test "adding and  listing peers", %{peer_registry: peer_registry} do
    McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
    McamPeerRegistry.record_peer(peer_registry, "nerves-r2d3", {10, 1, 2, 4})

    assert [
             {"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.3:4000"},
             {"nerves-r2d3", "http://nerves-r2d3.local:4000", "http://10.1.2.4:4000"}
           ] == McamPeerRegistry.peers(peer_registry)
  end

  test "updating peer", %{peer_registry: peer_registry} do
    McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
    McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 4})

    assert [{"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.4:4000"}] ==
             McamPeerRegistry.peers(peer_registry)
  end

  test "timing out", %{peer_registry: peer_registry, registry_name: registry_name} do
    McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
    :sys.get_state(peer_registry)

    [{pid, _}] = Registry.lookup(registry_name, "nerves-gg8f")

    send(pid, :timeout)
    wait_for_death(pid)
    assert [] == McamPeerRegistry.peers(peer_registry)
  end

  describe "notification" do
    setup %{peer_registry: peer_registry} do
      McamPeerRegistry.subscribe(peer_registry)
      :ok
    end

    test "notified on new registration", %{peer_registry: peer_registry} do
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})

      assert_receive {:mcam_peer_registry, :update,
                      {"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.3:4000"}}
    end

    test "notified of updates", %{peer_registry: peer_registry} do
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 4})

      assert_receive {:mcam_peer_registry, :update,
                      {"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.4:4000"}}
    end

    test "not notified if the ip is not updated", %{peer_registry: peer_registry} do
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})

      assert_receive {:mcam_peer_registry, _, _}
      refute_receive {:mcam_peer_registry, _, _}
    end

    test "notified on update of ip, but not if it is not subsequently changed", %{
      peer_registry: peer_registry
    } do
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 4})
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 4})

      assert_receive {:mcam_peer_registry, :update,
                      {"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.3:4000"}}

      assert_receive {:mcam_peer_registry, :update,
                      {"nerves-gg8f", "http://nerves-gg8f.local:4000", "http://10.1.2.4:4000"}}

      refute_receive {:mcam_peer_registry, _, _}
    end

    test "notified of removal from the registry", %{
      peer_registry: peer_registry,
      registry_name: registry_name
    } do
      McamPeerRegistry.record_peer(peer_registry, "nerves-gg8f", {10, 1, 2, 3})
      :sys.get_state(peer_registry)

      [{pid, _}] = Registry.lookup(registry_name, "nerves-gg8f")
      send(pid, :timeout)

      assert_receive {:mcam_peer_registry, :removed, "nerves-gg8f"}
    end
  end

  defp wait_for_death(pid, countdown \\ 25)

  defp wait_for_death(_pid, 0) do
    flunk("process did not die")
  end

  defp wait_for_death(pid, countdown) do
    if Process.alive?(pid) do
      :timer.sleep(1)
      wait_for_death(pid, countdown - 1)
    end
  end
end
