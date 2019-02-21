defmodule ProhoundSlackCmdsTest do
  use ExUnit.Case
  doctest ProhoundSlackCmds

  test "greets the world" do
    assert ProhoundSlackCmds.hello() == :world
  end
end
