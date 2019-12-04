defmodule Wires do
  def load!(filename) do
    File.stream!(filename)
    |> Enum.map(fn line ->
      line
      |> String.trim
      |> String.split(",")
      |> Enum.map(fn << dir, dist :: binary >> -> {dir, String.to_integer(dist)} end)
    end)
  end

  def wire_to_seen_spaces(wire) do
    wire
    |> Enum.reduce({MapSet.new, {0, 0}}, fn {dir, len}, {seen, {cx, cy}} ->
      case dir do
        ?U -> {
          MapSet.union(seen, MapSet.new(Enum.map(cy..(cy+len), &({cx, &1})))),
          {cx, cy+len}
        }
        ?D -> {
          MapSet.union(seen, MapSet.new(Enum.map(cy..(cy-len), &({cx, &1})))),
          {cx, cy-len}
        }
        ?L -> {
          MapSet.union(seen, MapSet.new(Enum.map((cx-len)..cx, &({&1, cy})))),
          {cx-len, cy}
        }
        ?R -> {
          MapSet.union(seen, MapSet.new(Enum.map((cx+len)..cx, &({&1, cy})))),
          {cx+len, cy}
        }
      end
    end)
    |> elem(0)
    |> MapSet.delete({0,0})
  end

  def solve_1a(filename \\ "input.txt") do
    [w1, w2] = load!(filename) |> Enum.map(&wire_to_seen_spaces/1)
    MapSet.intersection(w1, w2)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min
  end
end
