defmodule Counter do
  def new(l) do
    l
    |> Enum.reduce(%{}, fn {spot, id}, acc ->
      Map.update(acc, spot, [id], &([id | &1]))
    end)
  end

  def max_overlaps(m) do
    m
    |> Enum.reduce(%{}, fn {spot, ids}, acc ->
      overlaps = length(ids)
      Enum.reduce(ids, acc, fn id, acc2 ->
        Map.update(acc2, id, 1, &max(&1, overlaps))
      end)
    end)
  end
end

File.stream!("input.txt")
|> Stream.flat_map(fn l ->
  m = Regex.run(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, l)
  [id, left, top, width, height] = m |> tl |> Enum.map(&String.to_integer/1)
  for row <- top..(top + height - 1),
      column <- left..(left + width - 1) do
    {column + row * 1000, id}
  end
end)
|> Counter.new
|> Counter.max_overlaps
|> Enum.filter(fn
  {id, 1} -> true
  {_, _} -> false
end)
|> IO.inspect

# 266

