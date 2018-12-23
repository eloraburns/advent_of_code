defmodule Caves do
  def new(target), do: %{{0, 0} => {0, 0}, target => {0, 0}}

  def geo2ero(geologic_index, depth) do
    geologic_index
    |> Kernel.+(depth)
    |> rem(20183)
  end

  def ero2type(erosion_index) do
    erosion_index
    |> rem(3)
  end

  def fill_x(m, depth, max_x) do
    1..max_x
    |> Enum.map(fn x ->
      geo = x * 16807
      ero = geo2ero(geo, depth)
      t = ero2type(ero)
      {{x, 0}, {ero, t}}
    end)
    |> Map.new
    |> Map.merge(m)
  end

  def fill_y(m, depth, max_y) do
    1..max_y
    |> Enum.map(fn y ->
      geo = y * 48271
      ero = geo2ero(geo, depth)
      t = ero2type(ero)
      {{0, y}, {ero, t}}
    end)
    |> Map.new
    |> Map.merge(m)
  end

  def fill_subregion(start_m, depth, max_x, max_y) do
    for x <- 1..max_x,
        y <- 1..max_y,
        not(x == max_x and y == max_y)
    do
      {x, y}
    end
    |> Enum.reduce(start_m, fn {x, y}, m ->
      left = elem(m[{x-1, y}], 0)
      up = elem(m[{x, y-1}], 0)
      geo = left * up
      ero = geo2ero(geo, depth)
      t = ero2type(ero)
      Map.put(m, {x, y}, {ero, t})
    end)
  end

  def fill_region(m, depth, to_x, to_y) do
    m
    |> fill_x(depth, to_x)
    |> fill_y(depth, to_y)
    |> fill_subregion(depth, to_x, to_y)
  end

  def show(m) do
    {maxx, maxy} = m
    |> Map.keys
    |> Enum.reduce({0, 0}, fn {x, y}, {maxx, maxy} -> {max(x, maxx), max(y, maxy)} end)
    for y <- 0..maxy do
      [
        for x <- 0..maxx do
          case elem(m[{x, y}], 1) do
            0 -> ?.
            1 -> ?=
            2 -> ?|
          end
        end,
        ?\n
      ]
    end
    |> IO.puts
  end

  def solve(depth \\ 8103, target_x \\ 9, target_y \\ 758) do
    new({target_x, target_y})
    |> fill_region(depth, target_x, target_y)
    |> Enum.map(fn {_, {_, t}} -> t end)
    |> Enum.sum
  end
  # 6952 is too low
end
