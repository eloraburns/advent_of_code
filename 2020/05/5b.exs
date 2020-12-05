defmodule A do
  def solve do
    used_seats = File.read!("input.txt")
    |> String.replace("F", "0")
    |> String.replace("B", "1")
    |> String.replace("R", "1")
    |> String.replace("L", "0")
    |> String.split
    |> Enum.map(&String.to_integer(&1, 2))
    |> MapSet.new

    first_seat = Enum.min(used_seats)
    last_seat = Enum.max(used_seats)
    [missing_seat] = for free? <- first_seat..last_seat,
      not MapSet.member?(used_seats, free?),
      MapSet.member?(used_seats, free? - 1),
      MapSet.member?(used_seats, free? + 1) do
        free?
    end
    missing_seat
  end
end

IO.puts A.solve
