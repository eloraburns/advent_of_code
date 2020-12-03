defmodule A do
  defmodule Hill do
    defstruct [
      width: 0,
      height: 0,
      rows: %{}
    ]

    def tree_at?(hill, column, row) do
      if Map.get(
          hill.rows[row],
          rem(column, hill.width),
          false
      ), do: 1, else: 0
    end
  end
      
  def parse(l) do
    l
    |> Enum.with_index
    |> Enum.reduce(%Hill{}, fn {stratum, row}, hill ->
      %Hill{ hill |
        width: stratum |> String.trim |> String.length, 
        height: row + 1,
        rows: Map.put(hill.rows, row, parse_stratum(stratum))
      }
    end)
  end

  defp parse_stratum(s) do
    for {tree?, i} <- s |> String.trim |> to_charlist |> Enum.with_index,
        into: %{} do
      {i, tree? == ?#}
    end
  end

  def solve do
    hill = File.stream!("input.txt") |> parse
    [
      {1, 1},
      {3, 1},
      {5, 1},
      {7, 1},
      {1, 2}
    ]
    |> Enum.map(&solve_route(hill, &1))
    |> Enum.reduce(fn a, b -> a * b end)
  end


  defp solve_route(hill, {right, down}) do
    {0, 0}
    |> Stream.iterate(fn {x, y} -> {x + right, y + down} end)
    |> Stream.take_while(fn {_x, y} -> y < hill.height end)
    |> Stream.map(fn {x, y} -> Hill.tree_at?(hill, x, y) end)
    |> Enum.sum
  end
end

IO.puts A.solve
