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

  def coefficient(in_digit, out_digit) do
    (in_digit + 1)
    |> div(out_digit + 1)
    |> rem(4)
    |> case do
      0 -> 0
      1 -> 1
      2 -> 0
      3 -> -1
    end
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

  def pv2int(l, acc \\ 0)
  def pv2int([], acc), do: acc
  def pv2int([h | t], acc), do: pv2int(t, (acc * 10) + h)

  def faststep(ints), do: faststep(Enum.reverse(ints), 0, [])
  def faststep([], _, acc), do: acc
  def faststep([d | rest], sum, acc) do
    newsum = sum + d
    newdig = newsum |> rem(10) |> abs
    faststep(rest, newsum, [ newdig | acc ])
  end

  def solve_1b(filename \\ "input.txt") do
    input = load!(filename)
    offset = input |> Enum.take(7) |> pv2int
    full_input = Enum.flat_map(1..10000, fn _ -> input end) |> Enum.drop(offset)
    # Make sure that this optimization works
    true = length(full_input) < offset
    Stream.iterate(full_input, fn s -> IO.inspect(:timer.tc fn -> faststep(s) end) |> elem(1) end)
    |> Stream.drop(100)
    |> Enum.take(1)
    |> hd
    |> Enum.take(8)
    |> Enum.map(&to_string/1)
    |> Enum.join("")
    # 80284420
  end
end
