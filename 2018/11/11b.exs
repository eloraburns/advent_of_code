defmodule Eleven do
  # Find the fuel cell's rack ID, which is its X coordinate plus 10.
  # Begin with a power level of the rack ID times the Y coordinate.
  # Increase the power level by the value of the grid serial number (your puzzle input).
  # Set the power level to itself multiplied by the rack ID.
  # Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
  # Subtract 5 from the power level.

  def abs_power_for(x, y, serial) do
    # (xy + 10y + serial)(x + 10)
    # xxy + 10xy + serial*x + 10xy + 10*serial
    # xxy + 20xy + (x+10)*serial
    # Hmm.
    rack_id = x + 10
    ((rack_id * y + serial) * rack_id)
    |> div(100)
    |> rem(10)
    |> Kernel.-(5)
  end

  def grid(serial) do
    for x <- 1..300, y <- 1..300 do
      {{x, y, 1}, abs_power_for(x, y, serial)}
    end
    |> Map.new
  end

  def powers_for_size(grid, size) when rem(size, 2) == 0 do
    h = div(size, 2)
    for x <- 1..(301 - size), y <- 1..(301 - size) do
      {x, y}
    end
    |> Enum.map( fn {x, y} ->
      a = Map.fetch!(grid, {x, y, h})
      b = Map.fetch!(grid, {x + h, y, h})
      c = Map.fetch!(grid, {x, y + h, h})
      d = Map.fetch!(grid, {x + h, y + h, h})
      {{x, y, size}, a + b + c + d}
    end)
    |> Map.new
  end
  def powers_for_size(grid, size) do
    hl = div(size, 2)
    hh = size - hl
    for x <- 1..(301 - size), y <- 1..(301 - size) do
      {x, y}
    end
    |> Enum.map( fn {x, y} ->
      a = Map.fetch!(grid, {x, y, hh})
      b = Map.fetch!(grid, {x + hh, y, hl})
      c = Map.fetch!(grid, {x, y + hh, hl})
      d = Map.fetch!(grid, {x + hl, y + hl, hh})
      e = Map.fetch!(grid, {x + hl, y + hl, 1})
      {{x, y, size}, a + b + c + d - e}
    end)
    |> Map.new
  end

  def total_powers(grid) do
    Enum.reduce(2..300, grid, fn size, g ->
      IO.puts "Calculating size #{size}..."
      Map.merge(g, powers_for_size(g, size))
    end)
  end

  def solve(serial \\ 7403) do
    grid(serial)
    |> total_powers()
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end

end
