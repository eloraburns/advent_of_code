File.stream!("input.txt")
|> Enum.map(fn x -> x |> String.trim |> String.to_integer end)
|> (fn l -> Enum.zip([l, tl(l), tl(tl(l))]) end).()
|> Enum.map(fn {a, b, c} -> a + b + c end)
|> (fn l -> Enum.zip(l, tl(l)) end).()
|> Enum.count(fn {a, b} -> a < b end)
|> IO.puts
