defmodule A do
  def parse(l) do
    [container, contents_binary] = String.split(l, " bags contain ", parts: 2)
    contents_list = Regex.scan(~r/(\d+) (\w+ \w+) bags?|(no other bags)/, contents_binary, capture: :all_but_first)
    {container, contents_list}
    # {"dark orange", [["1", "light blue"], ["2", "faded blue"]]}
  end

  defp make_edge(g, v1, v2) do
    :digraph.add_vertex(g, v1)
    :digraph.add_vertex(g, v2)
    :digraph.add_edge(g, v1, v2)
  end

  def to_graph(list_of_rules) do
    g = :digraph.new([:acyclic])
    Enum.each(list_of_rules, fn {container, contained} ->
      Enum.each(contained, fn
        [_num, bag] -> make_edge(g, container, bag)
        [_, _, none] -> make_edge(g, container, none)
      end)
    end)
    g
  end

  def how_many_can_reach(g, bag) do
    :digraph.vertices(g)
    |> Enum.reject(&(&1 == bag))
    |> Enum.map(fn source_bag ->
      case :digraph.get_path(g, source_bag, bag) do
        false -> 0
        _ -> 1
      end
    end)
    |> Enum.sum
  end

  def solve do
    File.stream!("input.txt")
    |> Enum.map(&parse/1)
    |> to_graph
    |> how_many_can_reach("shiny gold")
  end
end
