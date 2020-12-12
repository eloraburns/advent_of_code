defmodule A do
  def solve(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.sort
    |> Enum.reduce({0, 0, 0}, fn
      n, {p, o, t} when n - p == 1 -> {n, o + 1, t}
      n, {p, o, t} when n - p == 3 -> {n, o, t + 1}
    end)
    |> (fn {_, o, t} -> o * (t + 1) end).()
  end

  def test1_10a do
    IO.puts "expect 35"
    solve("test1.txt")
  end

  def test2_10a do
    IO.puts "expect 220"
    solve("test2.txt")
  end

  def solve10a do
    solve("input.txt")
  end
end

