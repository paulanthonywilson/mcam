defmodule ServerComms.EventsTest do
  use ExUnit.Case

  alias ServerComms.Events

  test "changing status event" do
    Events.subscribe()
    Events.broadcast_status_changed(:connected)

    assert_receive {:server_connection_status_changed, :connected}
  end
end
