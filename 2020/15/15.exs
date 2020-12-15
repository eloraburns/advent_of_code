defmodule A do
  @input [12,1,16,3,11,0]

  def test do
    [
      {[0,3,6], 436},
      {[1,3,2], 1},
      {[2,1,3], 10},
      {[1,2,3], 27},
      {[2,3,1], 78},
      {[3,2,1], 438},
      {[3,1,2], 1836}
    ]
    |> Enum.map(fn {start, expected} ->
      actual = solve(start, 2020)
      {actual == expected, start, expected, actual}
    end)
  end

  def solve(start, target) do
    start_acc = start
    |> Enum.with_index
    |> Enum.map(fn {x, i} -> {x, {i, i}} end)
    |> Map.new

    last_num = start
    |> Enum.reverse
    |> hd

    length(start)..(target-1)
    |> Enum.reduce({start_acc, last_num}, fn i, {acc, prev} ->
      {prev_location, prev_prev_location} = Map.get(acc, prev)
      this_num = prev_location - prev_prev_location
      {Map.update(acc, this_num, {i, i}, fn {x, _} -> {i, x} end), this_num}
    end)
    |> elem(1)
  end

  def solve15a do
    solve(@input, 2020)
  end

  def solve15b do
    solve(@input, 30000000)
  end
end
