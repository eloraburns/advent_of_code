g = :digraph.new([:acyclic])

orbits = File.stream!("input.txt")
|> Enum.map(&(&1 |> String.trim |> String.split(")")))

v_by_name = orbits |> Enum.concat |> MapSet.new |> Enum.map(fn name ->
  v = :digraph.add_vertex(g)
  {name, :digraph.add_vertex(g, v, name)}
end) |> Map.new

_edges = orbits |> Enum.map(fn [n1, n2] ->
  :digraph.add_edge(g, v_by_name[n1], v_by_name[n2])
end)

com_v = v_by_name["COM"]
path_lengths = Enum.map(Map.drop(v_by_name, ["COM"]), fn {_name, v} ->
  :digraph.get_path(g, com_v, v) |> tl |> length
end)

path_lengths |> Enum.sum |> IO.puts
# 308790
