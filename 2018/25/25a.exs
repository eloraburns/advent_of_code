defmodule Twentyfive do
  def load(filename \\ "input.txt") do
    File.stream!(filename)
    |> Enum.map(fn l ->
      l
      |> String.trim
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  @compile {:inline, distance: 2}
  def distance([a,b,c,d], [w,x,y,z]) do
    abs(a-w) + abs(b-x) + abs(c-y) + abs(d-z)
  end

  def constellate(points, constellations \\ [])
  def constellate([], constellations), do: constellations
  def constellate([p | points], constellations) do
    {yes, no} = Enum.split_with(constellations, fn c ->
      Enum.any?(c, fn this_point -> distance(this_point, p) <= 3 end)
    end)
    constellate(points, [ Enum.concat([[p] | yes]) | no ])
  end

  def solve(filename \\ "input.txt") do
    load(filename)
    |> constellate
    |> length
  end
end
