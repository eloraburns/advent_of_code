defmodule A do
  def parse(input) do
    [rules_s, _mine_s, theirs_s] = String.split(input, "\n\n")

    rules = rules_s
    |> String.split("\n")
    |> Enum.flat_map(fn r ->
      [_, r1a, r1b, r2a, r2b] = Regex.run(~r/: (\d+)-(\d+) or (\d+)-(\d+)$/, r)
      [String.to_integer(r1a)..String.to_integer(r1b), String.to_integer(r2a)..String.to_integer(r2b)]
    end)

    theirs = theirs_s
    |> String.split("\n")
    |> tl
    |> Enum.filter(&(byte_size(&1) > 0))
    |> Enum.flat_map(fn l ->
      String.split(l, ",")
      |> Enum.map(&String.to_integer/1)
    end)

    %{rules: rules, theirs: theirs}
  end

  def load(filename \\ "input.txt") do
    File.read!(filename)
  end

  def solve(input) do
    %{rules: rules, theirs: theirs} = parse(input)
    theirs
    |> Enum.filter(fn t ->
      not Enum.any?(rules, &(t in &1))
    end)
    |> Enum.sum
  end

  def test16a do
    load("test.txt") |> solve
  end

  def solve16a do
    load |> solve
  end

end
