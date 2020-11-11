defmodule ConfigureTest do
  use ExUnit.Case
  doctest Configure

  test "greets the world" do
    assert Configure.hello() == :world
  end
end
