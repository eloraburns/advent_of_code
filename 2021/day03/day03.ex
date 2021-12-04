defmodule Day03 do
  use Bitwise

  def test do
    lines = ~s(
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    ) |> String.split
    IO.inspect lines

    #IO.inspect solve3a(lines), label: "3aTEST"
    IO.inspect solve3b(lines), label: "3bTEST"
  end

  def solve do
    # 3982034 is wrong.
    # 3687446 is right!
    IO.inspect solve3a(File.stream!("input.txt")), label: "3a"
    IO.inspect solve3b(File.stream!("input.txt")), label: "3b"
  end

  def solve3a(lines) do
    counts = lines
    |> Stream.map(fn l ->
      l
      |> String.trim
      |> String.split("", trim: true)
      |> Enum.reverse
      |> Enum.with_index
      |> Enum.into(%{}, fn
        {"0", place} -> {place, {1, 0}}
        {"1", place} -> {place, {0, 1}}
      end)
    end)
    |> Enum.reduce(%{}, fn a, b ->
      Map.merge(b, a, fn _k, {z1, o1}, {z2, o2} ->
        {z1+z2, o1+o2}
      end)
    end)

    #IO.inspect counts

    gr = Map.keys(counts) |> Enum.sort(:desc) |> Enum.reduce(0, fn i, acc ->
      {z, o} = counts[i]
    #  IO.inspect {i, z, o, acc}, label: "gr i z o acc"
      bit = if z < o, do: 1, else: 0
    #  IO.inspect bit
      IO.inspect( (acc <<< 1) + bit, label: "gr out")
    end)
    er = Map.keys(counts) |> Enum.sort(:desc) |> Enum.reduce(0, fn i, acc ->
      {z, o} = counts[i]
      (acc <<< 1) + if z > o, do: 1, else: 0
    end)

    #IO.inspect "gr #{gr}, er #{er}"
    gr * er
  end

  def solve3b(lines) do
    ll = lines
    |> Enum.map(fn l ->
      l
      |> String.trim
      |> String.split("", trim: true)
    end)
    oxy = winnow(ll, 0, {"0", "1", "1"}) |> Enum.join("") |> Integer.parse(2) |> elem(0)
    co2 = winnow(ll, 0, {"1", "0", "0"}) |> Enum.join("") |> Integer.parse(2) |> elem(0)
    IO.inspect {oxy, co2}, label: "oxy co2"
    oxy * co2
  end

  def winnow([], _, _), do: raise "no lines left"
  def winnow([line], _, _), do: line
  def winnow(lines, at, {z, o, d}) do
    IO.inspect {Enum.count(lines), at, z, o}, label: :winnow
    if Enum.count(lines) < 10 do
      IO.inspect lines, label: :lines
    end
    if Enum.count(hd(lines)) < at do
      IO.inspect lines
      raise "lines are only #{Enum.count(hd(lines))} but we're at #{at}"
    end
    case most_common_at(lines, at) do
      "0" -> IO.puts("0 most common"); filter_at(lines, at, z)
      "1" -> IO.puts("1 most common"); filter_at(lines, at, o)
      :equal -> IO.puts("equal"); filter_at(lines, at, d)
    end
    |> winnow(at + 1, {z, o, d})
  end
    
  def filter_at(ll, i, v) do
    ll
    |> Enum.filter(&(Enum.at(&1, i) == v))
  end

  def most_common_at(ll, i) do
    counts = ll
    |> Enum.map(&Enum.at(&1, i))
    |> Enum.reduce(%{"0" => 0, "1" => 0}, fn d, a -> Map.update(a, d, 1, &(&1 + 1)) end)
    |> IO.inspect(label: "most common at #{i}")
    
    z = Map.get(counts, "0")
    o = Map.get(counts, "1")
    cond do
      z > o -> "0"
      o > z -> "1"
      true -> :equal
    end
  end

end
