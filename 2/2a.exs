defmodule Counter do
  def new(l) do
    l
    |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1))
    end)
  end

  def has_n(m, n) do
    if Enum.any?(m, fn {_, en} -> en == n end) do
      1
    else
      0
    end
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_charlist/1)
|> Stream.map(&Counter.new/1)
|> Enum.reduce({0, 0}, fn c, {twos, threes} ->
  {twos + Counter.has_n(c, 2), threes + Counter.has_n(c, 3)}
end)
|> (fn {twos, threes} -> twos * threes end).()
|> IO.puts
