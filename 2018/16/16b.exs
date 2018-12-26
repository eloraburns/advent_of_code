defmodule Sixteen do
  def load_examples(filename \\ "input.txt") do
    content = File.read!(filename)
    Regex.scan(
      ~r/Before: [[](\d+), (\d+), (\d+), (\d+)[]]\n(\d+) (\d+) (\d+) (\d+)\nAfter:\s+[[](\d+), (\d+), (\d+), (\d+)[]]\n/,
      content
    )
    |> Enum.map(fn x ->
      things = x
      |> tl
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk(4)
      %{
        before: things |> hd,
        instruction: things |> tl |> hd,
        after: things |> tl |> tl |> hd,
      }
    end)
  end

  def load_program(opcode_map, filename \\ "input.txt") do
    content = File.read!(filename)
    Regex.scan(
      ~r/(\d+) (\d+) (\d+) (\d+)\n/,
      content
    )
    |> Enum.map(fn [_ , i, a1, a2, a3] ->
      {
        opcode_map[String.to_integer(i)],
        String.to_integer(a1),
        String.to_integer(a2),
        String.to_integer(a3)
      }
    end)
  end

  def possible_opcodes(example) do
    {
      example.instruction |> hd,
      for inst <- Cpu.instructions,
        example.after == Cpu.execute(
          [inst | example.instruction |> tl] |> List.to_tuple,
          example.before
        )
      do
        inst
      end
      |> MapSet.new
    }
  end

  def deduce_opcodes() do
    wide_open = 0..15
    |> Enum.zip(Stream.cycle([Cpu.instructions |> MapSet.new]))
    |> Map.new
      
    for example <- load_examples() do
      possible_opcodes(example)
    end
    |> Enum.reduce(wide_open, fn {numeric, possibilities}, what_we_know ->
      Map.update(what_we_know, numeric, :wtf, &MapSet.intersection(&1, possibilities))
    end)
  end

  def rededuce(possibilities) do
    possibilities
    |> Enum.map(fn {k, map_v} -> {k, MapSet.to_list(map_v)} end)
    |> Map.new
    |> rededuce(%{})
  end

  def rededuce(possibilities, knowns) when map_size(possibilities) == 0, do: knowns
  def rededuce(possibilities, knowns) do
    {numeric, symbolic} = possibilities
    |> Enum.flat_map(fn
      {k, [v]} -> [{k, v}]
      _ -> []
    end)
    |> hd

    new_possibilities = possibilities
    |> Enum.flat_map(fn
      {^numeric, _} -> []
      {k, v} -> [{k, List.delete(v, symbolic)}]
    end)
    |> Map.new

    rededuce(new_possibilities, Map.put(knowns, numeric, symbolic))
  end

  def run([], regs), do: regs
  def run([i | p], regs) do
    run(p, Cpu.execute(i, regs))
  end

  def solve() do
    deduce_opcodes()
    |> rededuce()
    |> load_program("just_program.txt")
    |> run(Cpu.new)
    |> hd
  end
end
