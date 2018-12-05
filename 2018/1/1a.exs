File.stream!("input.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)
|> Enum.reduce(0, &Kernel.+/2)
|> IO.puts
