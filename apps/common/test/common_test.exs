defmodule CommonTest do
  use ExUnit.Case
  doctest Common

  test "own hostname_to_nerves_local_url/0" do
    assert Common.hostname_to_nerves_local_url() =~ ~r/http:\/\/.+\.local:4000/
  end
end
