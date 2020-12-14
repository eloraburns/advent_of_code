defmodule A do
  defstruct t: 0, busses: []

  def parse(filename \\ "input.txt") do
    filename
    |> File.read!
    |> String.split
    |> (fn [t, busses | _] ->
      %A{
        t: String.to_integer(t),
        busses: busses |> String.trim |> String.split(",") |> Enum.flat_map(fn
          "x" -> []
          n -> [String.to_integer(n)]
        end)
      }
    end).()
  end

  def solve(a) do
    IO.inspect a
    a.busses
    |> Enum.map(fn b ->
      IO.inspect {b - rem(a.t, b), b}
    end)
    |> Enum.min
    |> (fn {wait, bus} ->
      wait * bus
    end).()
  end

  def test10a do
    IO.puts "Expect 295"
    "test.txt"
    |> parse
    |> solve
  end

  def solve10a do
    "input.txt"
    |> parse
    |> solve
    # 29840 is too high
  end
end
