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

  def trace_beam(start_x, start_y, side_size \\ 10) do
    new_y = Stream.iterate({start_x, start_y, 1}, fn {x, y, _} -> {x, y + 1, deploy(x, y + 1)} end)
    |> Stream.drop_while(fn {_, _, t} -> t == 1 end)
    |> Enum.take(1)
    |> hd
    |> elem(1)
    |> Kernel.-(1)

    case deploy(start_x + (side_size - 1), new_y - (side_size - 1)) do
      1 -> {start_x, new_y - (side_size - 1)}
      0 -> trace_beam(start_x + 1, new_y, side_size)
    end
  end

  def solve_1b do
    {x, y} = trace_beam(20, 12, 100)
    x * 10000 + y
    # 13590767 is too high
    # 13530763 is too low
    # 13530764 (silly off by one)
  end
end
