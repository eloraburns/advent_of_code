defmodule A do
  use Bitwise, only_operators: true
  @full_mask 0b111111111111111111111111111111111111

  def load(filename) do
    File.stream!(filename)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn l ->
      case String.split(l, " = ") do
        ["mask", mask] ->
          {
            :mask,
            mask
            |> String.to_charlist
            |> Enum.reverse
            |> Enum.with_index
            |> Enum.reduce(%{a: @full_mask, o: 0, x: []}, fn
              {?1, i}, %{a: a, o: o, x: x} -> %{a: a, o: o ||| (1 <<< i), x: x}
              {?0, _}, %{a: a, o: o, x: x} -> %{a: a, o: o,               x: x}
              {?X, i}, %{a: a, o: o, x: x} -> %{a: a, o: o,               x: [i | x]}
            end)
            |> (fn %{a: a, o: o, x: x} ->
              Enum.reduce(x, [%{a: a, o: o}], fn i, l ->
                Enum.map(l, fn %{a: a, o: o} ->
                  %{a: a, o: o ||| (1 <<< i)}
                end) ++ Enum.map(l, fn %{a: a, o: o} ->
                  %{a: a ^^^ (1 <<< i), o: o}
                end)
              end)
            end).()
          }
        [<< "mem[", paddr::binary >>, value] ->
          {addr, "]"} = Integer.parse(paddr)
          {:set, addr, String.to_integer(value)}
      end
    end)
  end

  def run(program) do
    Enum.reduce(program, {%{a: @full_mask, o: 0}, %{}}, fn
      {:mask, mask}, {_, mem} -> {mask, mem}
      {:set, addr, value}, {mask, mem} ->
        {
          mask, 
          Enum.reduce(mask, mem, fn ma, me ->
            Map.put(me, (addr &&& ma.a) ||| ma.o, value)
          end)
        }
    end)
  end

  def solve({_mask, mem}) do
    mem
    |> Map.values
    |> Enum.sum
  end

  def test14b do
    "test2.txt"
    |> load
    |> run
    |> solve
  end

  def solve14b do
    "input.txt"
    |> load
    |> run
    |> solve
  end
end
