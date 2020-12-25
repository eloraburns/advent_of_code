defmodule Hex do
  def load(filename) do
    filename
    |> File.read!
    |> String.trim
    |> String.split("\n")
  end

  def parse_line(line, acc \\ [])
  def parse_line("", acc), do: Enum.reverse(acc)
  def parse_line(<< "e", rest::binary >>, acc), do: parse_line(rest, [:e | acc])
  def parse_line(<< "w", rest::binary >>, acc), do: parse_line(rest, [:w | acc])
  def parse_line(<< "se", rest::binary >>, acc), do: parse_line(rest, [:se | acc])
  def parse_line(<< "sw", rest::binary >>, acc), do: parse_line(rest, [:sw | acc])
  def parse_line(<< "ne", rest::binary >>, acc), do: parse_line(rest, [:ne | acc])
  def parse_line(<< "nw", rest::binary >>, acc), do: parse_line(rest, [:nw | acc])

  def parse(lines) do
    lines
    |> Enum.map(&parse_line/1)
  end

  def dir2vec(directions, position \\ {0, 0})
  def dir2vec([], position), do: position
  def dir2vec([:e | rest], {x, y}), do: dir2vec(rest, {x + 2, y})
  def dir2vec([:w | rest], {x, y}), do: dir2vec(rest, {x - 2, y})
  def dir2vec([:se | rest], {x, y}), do: dir2vec(rest, {x + 1, y + 1})
  def dir2vec([:sw | rest], {x, y}), do: dir2vec(rest, {x - 1, y + 1})
  def dir2vec([:ne | rest], {x, y}), do: dir2vec(rest, {x + 1, y - 1})
  def dir2vec([:nw | rest], {x, y}), do: dir2vec(rest, {x - 1, y - 1})

  def flipit(vectors) do
    Enum.reduce(vectors, %{}, fn v, m ->
      Map.update(m, v, :black, fn
        :black -> :white
        :white -> :black
      end)
    end)
  end

  def solvea(filename) do
    filename
    |> load
    |> IO.inspect
    |> parse
    |> IO.inspect
    |> Enum.map(&dir2vec/1)
    |> flipit
    |> IO.inspect
    |> Map.values
    |> Enum.count(&(&1 == :black))
  end

  def test24a do
    IO.puts "Expect 10"
    "test.txt"
    |> solvea
  end

  def solve24a do
    "input.txt"
    |> solvea
  end

  def get_check_coords(map) do
    map
    |> Enum.filter(fn {{x, y}, colour} -> colour == :black end)
    |> Enum.flat_map(fn {{x, y}, :black} ->
      [
        {x + 2, y},
        {x - 2, y},
        {x + 1, y + 1},
        {x - 1, y + 1},
        {x + 1, y - 1},
        {x - 1, y - 1},
        {x, y}
      ]
    end)
    |> MapSet.new
  end

  def step_cell({x, y}, map) do
    count = [
      {x + 2, y},
      {x - 2, y},
      {x + 1, y + 1},
      {x - 1, y + 1},
      {x + 1, y - 1},
      {x - 1, y - 1}
    ]
    |> Enum.map(fn coord -> Map.get(map, coord, :white) end)
    |> Enum.count(&(&1 == :black))

    {
      {x, y}, 
      case Map.get(map, {x, y}, :white) do
        :white when count == 2 -> :black
        :black when count == 1 or count == 2 -> :black
        _ -> :white
      end
    }
  end

  def step(map) do
    map
    |> get_check_coords
    |> Enum.map(&step_cell(&1, map))
    |> Map.new
  end

  def solveb(filename) do
    map = filename
    |> load
    |> parse
    |> Enum.map(&dir2vec/1)
    |> flipit

    1..100
    |> Enum.reduce(map, fn _, map ->
      step(map)
    end)
    |> Map.values
    |> Enum.count(&(&1 == :black))
  end

  def test24b do
    IO.puts "Expect 2208"
    "test.txt"
    |> solveb
  end

  def solve24b do
    "input.txt"
    |> solveb
  end

end
