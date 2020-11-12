defmodule FakeCowboy do
  @moduledoc """
  Fakes up a request for websockets containing parameters. As long as you
  are only interested in the 15th element it works.
  """

  def fake_req(params \\ []) do
    %{bindings: Enum.into(params, %{})}
  end
end
