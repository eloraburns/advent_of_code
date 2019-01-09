defmodule Eighteen do
  def load(filename \\ "input.txt") do
    File.stream!(filename)
    |> Stream.with_index
    |> Enum.flat_map(fn {l, y} ->
      l
      |> String.trim
      |> String.to_charlist
      |> Stream.with_index
      |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Map.new
  end

  def step(state) do
    state
    |> Enum.map(fn {coord, cell} ->
      {
        coord, 
        coord
        |> neighbours(state)
        |> next_for_cell(cell)
      }
    end)
    |> Map.new
  end

  def neighbours({x, y}, state) do
    [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y},                 {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1},
    ]
    |> Enum.map(&Map.get(state, &1))
    |> Enum.filter(&(&1))
    |> Enum.reduce(%{?| => 0, ?# => 0, ?. => 0}, fn cell, counts ->
      Map.update(counts, cell, 0, &(&1 + 1))
    end)
  end

  def next_for_cell(%{?| => trees}, ?.) when trees >= 3, do: ?|
  def next_for_cell(_, ?.), do: ?.
  def next_for_cell(%{?# => lumber}, ?|) when lumber >= 3, do: ?#
  def next_for_cell(_, ?|), do: ?|
  def next_for_cell(%{?| => trees, ?# => lumber}, ?#) when trees >= 1 and lumber >= 1, do: ?#
  def next_for_cell(_, ?#), do: ?.

  def score(state) do
    cells = Map.values(state)
    Enum.count(cells, &(&1 == ?|)) * Enum.count(cells, &(&1 == ?#))
  end

  def scores(filename \\ "input.txt") do
    filename
    |> load
    |> Stream.iterate(&step/1)
    |> Stream.map(&score/1)
    |> Stream.with_index
  end

  def score_at(minute) when minute >= 417 do
    index = rem(minute - 417, 28)
    [
      174028,
      170016,
      167445,
      161214,
      164666,
      165599,
      171970,
      176900,
      183084,
      189630,

      197938,
      205737,
      216216,
      215877,
      215096,
      215160,
      217728,
      217672,
      219726,
      214878,

      189088,
      191540,
      199593,
      199064,
      199283,
      186550,
      182252,
      176468,
    ] |> Enum.at(index)
  end
end
