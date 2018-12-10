defmodule Ten do

  def load() do
    File.stream!("input.txt")
    |> Enum.map(fn l ->
      Regex.run(~r/position=<\s*([+-]?\d+),\s*([+-]?\d+)> velocity=<\s*([+-]?\d+),\s*([+-]?\d+)>/, l)
      |> tl
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    end)
  end

  def bounds(points) do
    {x, y, _, _} = hd(points)
    points
    |> tl
    |> Enum.reduce({x, x, y, y}, fn {x, y, _, _}, {minx, maxx, miny, maxy} ->
      {min(x, minx), max(x, maxx), min(y, miny), max(y, maxy)}
    end)
  end

  def area(points) do
    {minx, maxx, miny, maxy} = points |> bounds
    (maxx - minx) * (maxy - miny)
  end

  def step(points) do
    points
    |> Enum.map(fn {x, y, dx, dy} -> {x + dx, y + dy, dx, dy} end)
  end

  def minimize_by(d, f, by) do
    minimize_by(d, by.(d), f, by)
  end

  defp minimize_by(d, v, f, by) do
    d2 = f.(d)
    v2 = by.(d2)
    if v2 >= v do
      d
    else
      minimize_by(d2, v2, f, by)
    end
  end

  def display(points) do
    {minx, maxx, miny, maxy} = points |> bounds
    stars = points |> Enum.map(fn {x, y, _, _} -> {x, y} end) |> MapSet.new
    for y <- miny..maxy do
      [
        for x <- minx..maxx do
          case Enum.member?(stars, {x, y}) do
            true -> ?#
            false -> ?.
          end
        end,
        "\n",
      ]
    end
    |> IO.puts
  end

  def solve() do
    load
    |> minimize_by(&step/1, &area/1)
    |> display
  end

end
