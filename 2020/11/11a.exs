defmodule A do
  def load(filename \\ "input.txt") do
    for {row, y} <- File.stream!(filename) |> Stream.with_index,
      {seat, x} <- row |> String.trim |> String.to_charlist |> Enum.with_index,
    into: %{} do
        {{x, y}, seat}
    end
  end

  def step_cell(m, x, y) do
    case Map.get(m, {x, y}) do
      ?. -> ?.
      ?L ->
        [Map.get(m, {x - 1, y - 1}, ?.), Map.get(m, {x    , y - 1}, ?.), Map.get(m, {x + 1, y - 1}, ?.),
        Map.get(m, {x - 1, y    }, ?.),                                 Map.get(m, {x + 1, y    }, ?.),
        Map.get(m, {x - 1, y + 1}, ?.), Map.get(m, {x    , y + 1}, ?.), Map.get(m, {x + 1, y + 1}, ?.)]
        |> Enum.count(&(&1 == ?#))
        |> case do
          0 -> ?#
          _ -> ?L
        end
      ?# ->
        [Map.get(m, {x - 1, y - 1}, ?.), Map.get(m, {x    , y - 1}, ?.), Map.get(m, {x + 1, y - 1}, ?.),
        Map.get(m, {x - 1, y    }, ?.),                                 Map.get(m, {x + 1, y    }, ?.),
        Map.get(m, {x - 1, y + 1}, ?.), Map.get(m, {x    , y + 1}, ?.), Map.get(m, {x + 1, y + 1}, ?.)]
        |> Enum.count(&(&1 == ?#))
        |> case do
          n when n >= 4 -> ?L
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
        {{x, y}, step_cell(m, x, y)}
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

  def test11a do
    "test.txt" |> load |> solve
  end

  def solve11a do
    "input.txt" |> load |> solve
  end
end
