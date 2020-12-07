defmodule A do
  def parse(l) do
    [container, contents_binary] = String.split(l, " bags contain ", parts: 2)
    contents_list = Regex.scan(~r/(\d+) (\w+ \w+) bags?|(no other bags)/, contents_binary, capture: :all_but_first)
    |> Enum.flat_map(fn
      [count, kind] -> Enum.map(1..String.to_integer(count), fn _ -> kind end)
      ["", "", "no other bags"] -> [nil]
    end)
    {container, contents_list}
    # {"dark orange", ["light blue", "faded blue", "faded blue"]}
  end

  def count(g, start_bag, bags_seen \\ 0, more_bags \\ [])
  def count(_g, nil, bags_seen, []) do
    bags_seen - 1
  end
  def count(g, nil, bags_seen, [h | t]) do
    count(g, h, bags_seen, t)
  end
  def count(g, bag, bags_seen, more_bags) do
    # Recursing on bag=nil so that both cases above are handled…above.
    count(g, nil, bags_seen + 1, Map.get(g, bag) ++ more_bags)
  end

  def solve do
    rules = File.stream!("input.txt")
    |> Enum.map(&parse/1)
    |> Map.new
    |> count("shiny gold")
  end
end
