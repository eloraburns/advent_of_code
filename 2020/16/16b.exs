defmodule A do
  def parse(input) do
    [rules_s, mine_s, theirs_s] = String.split(input, "\n\n")

    rules = rules_s
    |> String.split("\n")
    |> Enum.map(fn r ->
      [field, ranges] = String.split(r, ":")
      [_, r1a, r1b, r2a, r2b] = Regex.run(~r/^ (\d+)-(\d+) or (\d+)-(\d+)$/, ranges)
      {field, String.to_integer(r1a)..String.to_integer(r1b), String.to_integer(r2a)..String.to_integer(r2b)}
    end)

    mine = mine_s
    |> String.split("\n")
    |> tl |> hd
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    theirs = theirs_s
    |> String.trim
    |> String.split("\n")
    |> tl
    |> Enum.filter(&(byte_size(&1) > 0))
    |> Enum.map(fn l ->
      String.split(l, ",")
      |> Enum.map(&String.to_integer/1)
    end)

    rule_ranges = rules
    |> Enum.flat_map(fn {_field, r1, r2} -> [r1, r2] end)

    valid_passes = theirs
    |> Enum.filter(fn p ->
      Enum.all?(p, fn v ->
        Enum.any?(rule_ranges, &(v in &1))
      end)
    end)

    %{rules: rules, mine: mine, passes: valid_passes}
  end

  def load(filename \\ "input.txt") do
    File.read!(filename)
  end

  def listzip(enumerables, acc \\ [])
  def listzip([[] | _], acc), do: Enum.reverse(acc)
  def listzip(enumerables, acc) do
    listzip(
      Enum.map(enumerables, &tl/1),
      [Enum.map(enumerables, &hd/1) | acc]
    )
  end

  def sherlock(enumerables) do
    cond do
      Enum.all?(enumerables, &(length(&1) == 1)) ->
        enumerables |> Enum.map(&hd/1)
      Enum.any?(enumerables, &(length(&1) == 0)) ->
        raise "Found empty sublist: #{inspect enumerables}"
      true ->
        onesies = enumerables
        |> Enum.filter(fn
          [_] -> true
          _ -> false
        end)
        |> Enum.map(&hd/1)

        enumerables
        |> Enum.map(fn l ->
          Enum.reduce(onesies, l, fn
            o, [o] -> [o]
            o, acc -> List.delete(acc, o)
          end)
        end)
        |> sherlock
    end
  end


  def solve(input) do
    %{rules: rules, mine: mine, passes: passes} = parse(input)

    parallel_fields = listzip(passes)

    the_fields = parallel_fields
    |> Enum.map(fn f ->
      rules
      |> Enum.filter(fn {_name, r1, r2} ->
        Enum.all?(f, fn fv -> fv in r1 or fv in r2 end)
      end)
      |> Enum.map(&elem(&1, 0))
    end)
    |> sherlock

    IO.inspect the_fields

    Enum.zip(the_fields, mine)
    |> IO.inspect
    |> Enum.flat_map(fn
      {<< "departure", _::binary >>, value} -> [value]
      _ -> []
    end)
    |> Enum.reduce(fn x, y -> x * y end)
  end

  def test16b do
    load("test2.txt") |> solve
  end

  def solve16b do
    load() |> solve
    # 706 is too low
  end

end
