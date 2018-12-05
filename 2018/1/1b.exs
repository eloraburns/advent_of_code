File.stream!("input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)
|> Stream.cycle()
|> Stream.transform({0, MapSet.new([])}, fn d, {f, s} ->
  f2 = f + d
  s2 = MapSet.put(s, f)
  {[{f2, s2}], {f2, s2}}
end)
|> Stream.drop_while(fn {f, s} -> f not in s end)
|> Enum.take(1)
|> IO.puts
