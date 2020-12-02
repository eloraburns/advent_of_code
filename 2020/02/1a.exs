defmodule A do
  defmodule Rule do
    defstruct min: 0, max: 0, thing: ?a
  end

  defmodule Password do
    defstruct rule: nil, word: []
  end

  def parse(lines) do
    lines
    |> Enum.map(fn l ->
      [_, min, max, thing, password] = Regex.run(
        ~r/(\d+)-(\d+) (.): (.*)/, l)
      %Password{
        rule: %Rule{min: String.to_integer(min), max: String.to_integer(max), thing: String.to_charlist(thing) |> hd},
        word: String.to_charlist(password)
      }
    end)
  end

  def solve do
    File.stream!("input.txt")
    |> parse
    |> Enum.count(fn p ->
      times = Enum.count(p.word, fn c -> c == p.rule.thing end)
      p.rule.min <= times and times <= p.rule.max
    end)
  end
end

A.solve |> IO.inspect
