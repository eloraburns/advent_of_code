defmodule Counter do
  def new(l) do
    l
    |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1))
    end)
  end

  def count_over_1(m) do
    m
    |> Map.values
    |> Stream.map(fn
      x when x > 1 -> 1
      _ -> 0
    end)
    |> Enum.reduce(0, &Kernel.+/2)
  end
end

File.stream!("input.txt")
|> Stream.flat_map(fn l ->
  m = Regex.run(~r/@ (\d+),(\d+): (\d+)x(\d+)/, l)
  [left, top, width, height] = m |> tl |> Enum.map(&String.to_integer/1)
  for row <- top..(top + height - 1),
      column <- left..(left + width - 1) do
    column + row * 1000
  end
end)
|> Counter.new
|> Counter.count_over_1
|> IO.puts

# 111266
