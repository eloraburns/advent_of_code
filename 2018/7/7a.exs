defmodule Seven do

  def load_graph() do
    File.stream!("input.txt")
    |> Enum.map(fn << "Step ", a, " must be finished before step ", b, " can begin.\n" >> -> {a, b} end)
    |> Enum.reduce(%{}, fn {a, b}, acc ->
      acc
      |> Map.update(a, [b], &([b|&1]))
      |> Map.put_new(b, [])
    end)
  end

  def find_empty_incoming(g) do
    all_targets = g
    |> Map.values
    |> Enum.concat
    |> MapSet.new

    empty_incoming = g
    |> Map.keys
    |> MapSet.new
    |> MapSet.difference(all_targets)
    |> Enum.sort
  end

  def solve(g, sorted) when map_size(g) == 0, do: Enum.reverse(sorted)
  def solve(g, sorted) do
    n = g |> find_empty_incoming |> hd
    solve(Map.drop(g, [n]), [n | sorted])
  end

  def solve() do
    g = load_graph()
    solve(g, [])
  end
end
