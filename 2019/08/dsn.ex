defmodule Dsn do
  def solve_1a(width, height, filename \\ "input.txt") do
    File.read!(filename)
    |> String.trim
    |> String.split("", trim: true)
    |> Enum.chunk_every(width * height)
    |> Enum.map(fn layer ->
      Enum.reduce(layer, %{}, fn px, counts ->
        Map.update(counts, px, 1, &(&1 + 1))
      end)
    end)
    |> Enum.min_by(fn counts -> Map.get(counts, "0", 0) end)
    |> (fn counts -> Map.get(counts, "1", 0) * Map.get(counts, "2", 0) end).()
    # 2135 is too high (that's for max zeroes, not min zeros!)
    # 1320
  end

  def pixel_value(["0" | _]), do: " "
  def pixel_value(["1" | _]), do: "*"
  def pixel_value([_ | t]), do: pixel_value(t)

  def solve_1b(width, height, filename \\ "input.txt") do
    File.read!(filename)
    |> String.trim
    |> String.split("", trim: true)
    |> Enum.chunk_every(width * height)
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
    |> IO.inspect
    |> Enum.map(&pixel_value/1)
    |> Enum.chunk_every(width)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.join("\n")
    |> IO.puts
    # RCYKR
  end
end
