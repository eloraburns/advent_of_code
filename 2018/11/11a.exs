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
    # The minus 5 at the end really doesn't do anything overall
  end

  def grid(serial) do
    for x <- 1..300, y <- 1..300 do
      {{x, y}, abs_power_for(x, y, serial)}
    end
    |> Map.new
  end

  def total_powers(grid) do
    for x <- 1..298, y <- 1..298 do
      {
        {x, y}, 
        for dx <- 0..2, dy <- 0..2 do
          grid[{x+dx, y+dy}]
        end |> Enum.sum
      }
    end
  end

  def solve(serial \\ 7403) do
    grid(serial)
    |> total_powers()
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end

end
