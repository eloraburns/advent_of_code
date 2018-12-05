File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.flat_map(fn s ->
  l = String.length(s)
  [0..(l-1), 1..l, (l-1)..0] |> Enum.zip
  |> Enum.map(fn {x, y, z} ->
    {x, String.slice(s, 0, x) <> String.slice(s, y, z)}
  end)
end)
|> Enum.reduce({MapSet.new, nil}, fn
  id, {seen, dupe} ->
    if id in seen do
      {seen, id}
    else
      {MapSet.put(seen, id), dupe}
    end
end)
|> elem(1)
|> elem(1)
|> IO.puts

#ovfqobidheyujztrsvxmkgnap is not it
