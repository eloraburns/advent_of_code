defmodule Six_b do
  def get_points do
    points = File.stream!("input.txt")
    |> Stream.map(fn s -> s |> String.trim |> String.split(", ") |> Enum.map(&String.to_integer/1) end)
  end

  def solve() do
    points = get_points()
    for x <- 43..356,
      y <- 43..356
    do
      points
      |> Enum.reduce(0, fn [px, py], total_dist ->
        total_dist + abs(px - x) + abs(py - y)
      end)
    end |> Enum.filter(&(&1 < 10000)) |> Enum.count
  end
end
