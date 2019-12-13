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

youpart = :digraph.get_path(g, v_by_name["COM"], v_by_name["YOU"])
sanpart = :digraph.get_path(g, v_by_name["COM"], v_by_name["SAN"])

defmodule C do
  def strip_common([h | t1], [h | t2]), do: strip_common(t1, t2)
  def strip_common(l1, l2), do: [l1, l2]
end

C.strip_common(youpart, sanpart) |> Enum.map(&length/1) |> Enum.sum |> Kernel.-(2) |> IO.puts
# 471 is too low
# Because I did -3, forgetting that strip_common takes out one required hop!
