defmodule GoblinCaveTest do
  use ExUnit.Case
  doctest GoblinCave

  test "greets the world" do
    assert GoblinCave.hello() == :world
  end
end
