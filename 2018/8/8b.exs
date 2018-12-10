defmodule Eight do
  def read() do
    File.read!("input.txt")
    |> String.split
    |> Enum.map(&String.to_integer/1)
  end

  def node_value([0, num_metadata | rest]) do
    {metas, rest2} = Enum.split(rest, num_metadata)
    {rest2, Enum.sum(metas)}
  end

  def node_value([num_children, num_metadata | rest]) do
    {rest2, child_values} = Enum.reduce(1..num_children, {rest, []}, fn i, {r, a} ->
      {r2, v} = node_value(r)
      {r2, [{i, v} | a]}
    end)
    child_map = Map.new(child_values)
    {metas, rest3} = Enum.split(rest2, num_metadata)
    value = Enum.reduce(metas, 0, &(Map.get(child_map, &1, 0) + &2))
    {rest3, value}
  end

  def solve() do
    read()
    |> node_value()
    |> elem(1)
  end
end
