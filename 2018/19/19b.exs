1..10551364 |> Enum.filter(fn x -> rem(10551364, x) == 0 end) |> Enum.sum |> IO.puts
