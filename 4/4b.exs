defmodule C do
  def most_populous(guards) do
    guards
    |> Enum.max_by(fn {_guard_id, minutes} ->
      minutes
      |> Map.values
      |> Enum.reduce(0, &max/2)
    end)
  end

  def most_frequent(minutes) do
    minutes
    |> Enum.max_by(fn {_minute, count} -> count end)
  end
end

File.stream!("input.txt")
|> Enum.sort
|> Stream.map(&Regex.run(~r/(\d\d)[]] (Guard #(\d+) begins shift|falls asleep|wakes up)/, &1))
|> Stream.transform({nil, nil}, fn
  [_, _, _, guard_id], {_, _} ->
    {[], {guard_id |> String.to_integer, nil}}
  [_, minute, "falls asleep"], {guard_id, nil} ->
    {[], {guard_id, minute |> String.to_integer}}
  [_, minute, "wakes up"], {guard_id, falls_asleep} ->
    sleep_range = falls_asleep..(minute |> String.to_integer |> Kernel.-(1))
    {Enum.map(sleep_range, &({guard_id, &1})), {guard_id, nil}}
end)
|> Enum.reduce(%{}, fn {guard_id, minute}, acc ->
  Map.update(acc, guard_id, %{minute => 1}, fn minutes ->
    Map.update(minutes, minute, 1, &(&1 + 1))
  end)
end)
|> (fn guards ->
  {guard_id, minutes} = C.most_populous(guards)
  {minute, _} = C.most_frequent(minutes)
  guard_id * minute
end).()
|> IO.puts
  
# 10491
