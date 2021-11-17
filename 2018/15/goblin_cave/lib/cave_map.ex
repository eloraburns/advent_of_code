defmodule CaveMap do
  defstruct cave: %{}, mobs: [], xrange: 0..0, yrange: 0..0

  def load(filename \\ "input.txt") do
    raw = raw_from_file(filename)
    {maxx, maxy} = Enum.reduce(raw, {0, 0}, fn {{x, y}, _}, {maxx, maxy} ->
      {max(x, maxx), max(y, maxy)}
    end)
    {spaces, mobs} = extract_mobs(raw)
    %CaveMap{
      cave: MapSet.new(spaces),
      mobs: mobs,
      xrange: 0..(maxx + 1),
      yrange: 0..(maxy + 1),
    }
  end

  def raw_from_file(filename) do
    filename
    |> File.stream!
    |> Stream.with_index
    |> Stream.flat_map(fn {l, y} ->
      l
      |> String.to_charlist
      |> Stream.with_index
      |> Stream.flat_map(fn
        {c, x} when c in [?., ?G, ?E] -> [{{x, y}, c}]
        _ -> []
      end)
    end)
    |> Map.new
  end


  def extract_mobs(m) do
    {
      Map.keys(m),
      m |> Enum.filter(fn {_, c} -> c != ?. end) |> Enum.sort
    }
  end
end

defimpl Inspect, for: CaveMap do
  def inspect(m, _opts) do
    mobmap = Map.new(m.mobs)
    for y <- m.yrange do
      for x <- m.xrange do
        Map.get(mobmap, {x, y}, (if MapSet.member?(m.cave, {x, y}), do: ?., else: ?#))
      end ++ [?\n]
    end
    |> IO.iodata_to_binary
  end
end
