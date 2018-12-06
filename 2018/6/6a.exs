defmodule Six_a do
  def get_points do
    points = File.stream!("input.txt")
    |> Stream.map(fn s -> s |> String.trim |> String.split(", ") |> Enum.map(&String.to_integer/1) end)
    |> Stream.zip(Stream.iterate(0, &(&1 + 1)))
  end

  def calculate_distances(points) do
    for x <- 44..355 do
      for y <- 44..355 do
        points
        |> Enum.reduce({nil, nil}, fn {[px, py], ix}, {min_ix, dist} ->
          pdist = abs(px - x) + abs(py - y)
          cond do
            pdist < dist -> {ix, pdist}
            pdist == dist -> {nil, dist}
            true -> {min_ix, dist}
          end
        end)
      end
    end
  end

  def border_indexes(distances) do
    left = distances |> List.first
    right = distances |> List.last
    top = distances |> Enum.map(&List.first/1)
    bottom = distances |> Enum.map(&List.last/1)
    [left, right, top, bottom] |> Enum.concat |> Enum.map(&elem(&1, 0)) |> MapSet.new |> MapSet.to_list
  end

  def population(distances) do
    distances |> Enum.concat |> Enum.map(&elem(&1, 0)) |> Enum.reduce(%{}, &Map.update(&2, &1, 1, fn i -> i + 1 end))
  end

  def solve do
    distances = get_points() |> calculate_distances()
    borders = distances |> border_indexes()
    distances |> population() |> Map.drop(borders) |> Enum.max_by(fn {ix, pop} -> pop end)
  end
end


#points |> Enum.flat_map(fn [x, y] -> [x] end) |> Enum.min |> IO.inspect
#points |> Enum.flat_map(fn [x, y] -> [x] end) |> Enum.max |> IO.inspect
#points |> Enum.flat_map(fn [x, y] -> [y] end) |> Enum.min |> IO.inspect
#points |> Enum.flat_map(fn [x, y] -> [y] end) |> Enum.max |> IO.inspect

