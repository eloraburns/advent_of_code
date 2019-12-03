File.stream!("input.txt")
|> Enum.map(fn t ->
  t
  |> String.trim
  |> String.to_integer
  |> div(3)
  |> Kernel.+(-2)
end)
|> Enum.reduce(0, &Kernel.+/2)
|> IO.puts
