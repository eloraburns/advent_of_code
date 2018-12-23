defmodule Nanobots do
  require Record
  Record.defrecord :bot, ~w(x y z r)a

  def load(filename \\ "input.txt") do
    File.stream!(filename)
    |> Enum.map(fn l ->
      Regex.run(~r/pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)\n/, l)
      |> tl
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [x, y, z, r] -> bot(x: x, y: y, z: z, r: r) end)
  end

  def biggest_bot(bots) do
    bots
    |> Enum.reduce(fn
      (bot(r: thisr) = thisbot, bot(r: maxr)) when thisr > maxr ->
        thisbot
      _, maxbot -> maxbot
    end)
  end

  def distance(bot(x: x1, y: y1, z: z1), bot(x: x2, y: y2, z: z2)) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  def solve(filename \\ "input.txt") do
    bots = load(filename)
    biggest = bot(r: biggest_r) = biggest_bot(bots)
    bots
    |> Enum.filter(fn b -> distance(b, biggest) <= biggest_r end)
    |> length
  end

end
