defmodule Eight do
  def read() do
    File.read!("input.txt")
    |> String.split
    |> Enum.map(&String.to_integer/1)
  end

  def collect_metadata([0, num_metadata | rest], acc) do
    {metas, rest2} = Enum.split(rest, num_metadata)
    {rest2, metas ++ acc}
  end

  def collect_metadata([num_children, num_metadata | rest], acc) do
    {rest2, acc2} = Enum.reduce(1..num_children, {rest, acc}, fn _, {r, a} ->
      collect_metadata(r, a)
    end)
    {metas, rest3} = Enum.split(rest2, num_metadata)
    {rest3, metas ++ acc2}
  end

  def solve() do
    read()
    |> collect_metadata([])
    |> elem(1)
    |> Enum.sum
  end
end
