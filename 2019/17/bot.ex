defmodule Bot do
  require Intcode

  def run_and_capture_output(code, output \\ []) do
    case Intcode.run(code) do
      {:made_output, intcode} ->
        run_and_capture_output(intcode, [ intcode.output | output ])
      {:halt, _} ->
        output
        |> Enum.chunk_while([],
          fn
            ?\n, acc -> {:cont, acc, []}
            e, acc -> {:cont, [ e | acc ]}
          end,
          fn acc -> {:cont, acc, []} end
        )
        |> Enum.reverse
    end
  end

  def solve_1a do
    map = Intcode.load!("input.txt")
    |> run_and_capture_output

    height = map |> length
    width = map |> hd |> length

    mapmap = for {row, y} <- Enum.with_index(map) do
      for {cell, x} <- Enum.with_index(row) do
        {{x, y}, cell}
      end
    end
    |> Enum.concat
    |> Enum.into(%{})

    for x <- 1..(width - 1) do
      for y <- 1..(height - 1) do
        case [
          Map.get(mapmap, {x, y}),
          Map.get(mapmap, {x + 1, y}),
          Map.get(mapmap, {x - 1, y}),
          Map.get(mapmap, {x, y + 1}),
          Map.get(mapmap, {x, y - 1}),
        ] do
          '#####' -> x * y
          _ -> 0
        end
      end
    end
    |> Enum.concat
    |> Enum.sum
    
  end
end
