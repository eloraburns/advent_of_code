defmodule A do
  def solve do
    File.read!("input.txt")
    |> String.replace("F", "0")
    |> String.replace("B", "1")
    |> String.replace("R", "1")
    |> String.replace("L", "0")
    |> String.split
    |> Enum.map(&String.to_integer(&1, 2))
    |> Enum.max
  end
end

IO.puts A.solve
