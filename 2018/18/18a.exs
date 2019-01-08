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

  def solve(filename \\ "input.txt") do
    filename
    |> load
    |> step
    |> step
    |> step
    |> step
    |> step
    |> step
    |> step
    |> step
    |> step
    |> step
    |> score
  end
end
