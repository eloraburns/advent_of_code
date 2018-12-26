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

  def test_example(example) do
    for inst <- Cpu.instructions,
      example.after == Cpu.execute(
        [inst | example.instruction |> tl] |> List.to_tuple,
        example.before
      )
    do
      1
    end
    |> Enum.sum
  end

  def solve() do
    for example <- load_examples(),
      test_example(example) >= 3
    do
      1
    end
    |> Enum.sum
  end
  # 567
end
