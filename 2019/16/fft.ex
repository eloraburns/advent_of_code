defmodule FFT do
  def load!(filename) do
    File.read!(filename)
    |> String.trim
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def coefficients(n) do
    for row <- 1..n do
      (
        Enum.map(1..row, fn _ -> 0 end) ++ 
        Enum.map(1..row, fn _ -> 1 end) ++ 
        Enum.map(1..row, fn _ -> 0 end) ++ 
        Enum.map(1..row, fn _ -> -1 end)
      )
      |> Stream.cycle
      |> Stream.drop(1)
      |> Enum.take(n)
    end
    |> Enum.concat
  end

  def step(data, coeffs) do
    data
    |> Stream.cycle
    |> Enum.zip(coeffs)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.chunk_every(length(data))
    |> Enum.map(fn r ->
      r
      |> Enum.sum
      |> rem(10)
      |> abs()
    end)
  end

  def solve_1a(filename \\ "input.txt") do
    input = load!(filename)
    coeffs = coefficients(length(input))
    Stream.iterate(input, &step(&1, coeffs))
    |> Stream.drop(100)
    |> Enum.take(1)
    |> hd
    |> Enum.take(8)
    |> Enum.map(&to_string/1)
    |> Enum.join("")
    # 73127523...in 26s
  end
end
