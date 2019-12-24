defmodule Drone do
  require Intcode

  @code Intcode.load!("input.txt")

  def deploy(x, y) do
    {:need_input, intcode} = Intcode.run(@code)
    {:need_input, intcode} = Intcode.run(%Intcode{ intcode | input: x })
    {:made_output, intcode} = Intcode.run(%Intcode{ intcode | input: y })
    intcode.output
  end

  def solve_1a(size \\ 50) do
    for y <- 0..(size - 1) do
      for x <- 0..(size - 1) do
        deploy(x, y)
      end
    end
    |> Enum.concat
    |> Enum.sum
  end

  def show(size \\ 50) do
    for y <- 0..(size - 1) do
      for x <- 0..(size - 1) do
        case deploy(x, y) do
          0 -> "."
          1 -> "#"
        end
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
    |> IO.puts
  end

  def trace_beam(start_x, start_y, row_east, col_south, side_size \\ 10) do
    IO.inspect {start_x, start_y, row_east, col_south}
    new_row_east = Stream.iterate({row_east, start_y, 1}, fn {x, y, _} -> {x + 1, y, deploy(x + 1, y)} end)
    |> Stream.drop_while(fn {_, _, t} -> t == 1 end)
    |> Enum.take(1)
    |> hd
    |> elem(0)
    |> Kernel.-(1)

    new_col_south = Stream.iterate({start_x, col_south, 1}, fn {x, y, _} -> {x, y + 1, deploy(x, y + 1)} end)
    |> Stream.drop_while(fn {_, _, t} -> t == 1 end)
    |> Enum.take(1)
    |> hd
    |> elem(1)
    |> Kernel.-(1)

    case {row_east - start_x + 1, col_south - start_y + 1} do
      {^side_size, ^side_size} -> {start_x, start_y}
      {dx, dy} when dx < dy -> trace_beam(start_x, start_y + 1, new_row_east, new_col_south, side_size)
      {dx, dy} when dx > dy -> trace_beam(start_x + 1, start_y, new_row_east, new_col_south, side_size)
      _ -> trace_beam(start_x + 1, start_y + 1, new_row_east, new_col_south, side_size)
    end
  end

  def solve_1b do
    {x, y} = trace_beam(20, 12, 20, 12, 100)
    x * 10000 + y
    # 13590767 is too high
  end
end
