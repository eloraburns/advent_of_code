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

  def wire_to_path(wire) do
    wire
    |> Enum.flat_map_reduce({0, 0}, fn {dir, len}, {cx, cy} ->
      case dir do
        ?U -> {
          Enum.map((cy+1)..(cy+len), &({cx, &1})),
          {cx, cy+len}
        }
        ?D -> {
          Enum.map((cy-1)..(cy-len), &({cx, &1})),
          {cx, cy-len}
        }
        ?L -> {
          Enum.map((cx-1)..(cx-len), &({&1, cy})),
          {cx-len, cy}
        }
        ?R -> {
          Enum.map((cx+1)..(cx+len), &({&1, cy})),
          {cx+len, cy}
        }
      end
    end)
    |> elem(0)
  end

  def index_of({x, y}, wire) do
    wire
    |> Enum.with_index(1)
    |> Enum.find(fn {{wx, wy}, _i} -> wx == x and wy == y end)
    |> elem(1)
  end

  def solve_1a(filename \\ "input.txt") do
    [w1, w2] = load!(filename) |> Enum.map(&wire_to_path/1) |> Enum.map(&MapSet.new/1)
    MapSet.intersection(w1, w2)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min
  end

  def solve_1b(filename \\ "input.txt") do
    [w1, w2] = load!(filename) |> Enum.map(&wire_to_path/1)
    MapSet.intersection(MapSet.new(w1), MapSet.new(w2))
    |> Enum.map(fn coord ->
      index_of(coord, w1) + index_of(coord, w2)
    end)
    |> Enum.min
  end
end
