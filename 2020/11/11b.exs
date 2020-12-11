defmodule A do
  def load(filename \\ "input.txt") do
    for {row, y} <- File.stream!(filename) |> Stream.with_index,
      {seat, x} <- row |> String.trim |> String.to_charlist |> Enum.with_index,
    into: %{} do
        {{x, y}, seat}
    end
  end

  def peer(_m, x, y, maxx, maxy, dirx, diry) when (x + dirx) < 0 or (y + diry) < 0 or (x + dirx) > maxx or (y + diry) > maxy, do: ?.
  def peer(m, x, y, maxx, maxy, dirx, diry) do
    case Map.get(m, {x + dirx, y + diry}) do
      ?. -> peer(m, x + dirx, y + diry, maxx, maxy, dirx, diry)
      ?# -> ?#
      ?L -> ?L
    end
  end

  def step_cell(m, x, y, maxx, maxy) do
    case Map.get(m, {x, y}) do
      ?. -> ?.
      ?L ->
        [peer(m, x, y, maxx, maxy, -1, -1), peer(m, x, y, maxx, maxy,  0, -1), peer(m, x, y, maxx, maxy, +1, -1),
         peer(m, x, y, maxx, maxy, -1,  0),                                    peer(m, x, y, maxx, maxy, +1,  0),
         peer(m, x, y, maxx, maxy, -1, +1), peer(m, x, y, maxx, maxy,  0, +1), peer(m, x, y, maxx, maxy, +1, +1)]
        |> Enum.count(&(&1 == ?#))
        |> case do
          0 -> ?#
          _ -> ?L
        end
      ?# ->
        [peer(m, x, y, maxx, maxy, -1, -1), peer(m, x, y, maxx, maxy,  0, -1), peer(m, x, y, maxx, maxy, +1, -1),
         peer(m, x, y, maxx, maxy, -1,  0),                                    peer(m, x, y, maxx, maxy, +1,  0),
         peer(m, x, y, maxx, maxy, -1, +1), peer(m, x, y, maxx, maxy,  0, +1), peer(m, x, y, maxx, maxy, +1, +1)]
        |> Enum.count(&(&1 == ?#))
        |> case do
          n when n >= 5 -> ?L
          _ -> ?#
        end
    end
  end

  def step(m) do
    keys = Map.keys(m)
    {minx, miny} = Enum.min(keys)
    {maxx, maxy} = Enum.max(keys)
    for y <- miny..maxy,
      x <- minx..maxx do
        {{x, y}, step_cell(m, x, y, maxx, maxy)}
    end
    |> Map.new
  end

  def to_string(m) do
    keys = Map.keys(m)
    {minx, miny} = Enum.min(keys)
    {maxx, maxy} = Enum.max(keys)
    for y <- miny..maxy do
      for x <- minx..maxx do
        Map.get(m, {x, y})
      end
    end
    |> Enum.intersperse(?\n)
  end

  def solve(new_m, old_m \\ nil)
  def solve(old_m, old_m) do
    old_m
    |> Map.values
    |> Enum.count(&(&1 == ?#))
  end
  def solve(m, _) do
    step(m) |> solve(m)
  end

  def test11b do
    IO.puts "Should be 26"
    "test.txt" |> load |> solve
  end

  def solve11b do
    "input.txt" |> load |> solve
  end
end
