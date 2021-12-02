defmodule Day02 do

  def solve2a do
    File.stream!("input.txt")
    |> Enum.map(fn l ->
      [dir, <<amt>>] = l |> String.trim |> String.split(" ")
      {dir, amt - ?0}
    end)
    |> Enum.reduce({0, 0}, fn
      {"forward", amt}, {x, y} -> {x + amt, y}
      {"down", amt}, {x, y} -> {x, y + amt}
      {"up", amt}, {x, y} -> {x, y - amt}
    end)
    |> (fn {x, y} -> x * y end).()
    |> IO.puts
  end

  def solve2b do
    File.stream!("input.txt")
    |> Enum.map(fn l ->
      [dir, <<amt>>] = l |> String.trim |> String.split(" ")
      {dir, amt - ?0}
    end)
    |> Enum.reduce({0, 0, 0}, fn
      {"forward", amt}, {x, y, aim} -> {x + amt, y + aim * amt, aim}
      {"down", amt}, {x, y, aim} -> {x, y, aim + amt}
      {"up", amt}, {x, y, aim} -> {x, y, aim - amt}
    end)
    |> (fn {x, y, _aim} -> x * y end).()
    |> IO.puts
  end

end
