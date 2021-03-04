defmodule LocalBroadcast.EventsTest do
  use ExUnit.Case

  alias LocalBroadcast.Events

  test "subscribe and receive" do
    Events.subscribe("topic1")

    Events.broadcast("topic1", :my_event)
    Events.broadcast("topic2", :not_my_event)
    assert_receive :my_event
    refute_receive :not_my_event
  end
end
