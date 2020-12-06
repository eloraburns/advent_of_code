File.read!("input.txt")
|> String.split("\n\n")
|> Enum.map(fn g ->
  g
  |> String.replace("\n", "")
  |> String.to_charlist
  |> MapSet.new
  |> MapSet.size
end)
|> Enum.sum
|> IO.puts
