File.read!("input.txt")
|> String.split("\n\n")
|> Enum.map(fn g ->
  g
  |> String.split
  |> Enum.map(fn p ->
    p
    |> String.to_charlist
    |> MapSet.new
  end)
  |> Enum.reduce(&MapSet.intersection/2)
  |> MapSet.size
end)
|> Enum.sum
|> IO.puts
