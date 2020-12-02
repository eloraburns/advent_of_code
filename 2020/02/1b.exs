defmodule A do
  defmodule Rule do
    defstruct pos1: 0, pos2: 0, thing: ?a
  end

  defmodule Password do
    defstruct rule: nil, word: []
  end

  def parse(lines) do
    lines
    |> Enum.map(fn l ->
      [_, pos1, pos2, thing, password] = Regex.run(
        ~r/(\d+)-(\d+) (.): (.*)/, l)
      %Password{
        rule: %Rule{pos1: String.to_integer(pos1), pos2: String.to_integer(pos2), thing: String.to_charlist(thing) |> hd},
        word: String.to_charlist(password)
      }
    end)
  end

  def solve do
    File.stream!("input.txt")
    |> parse
    |> Enum.count(fn p ->
      p1? = Enum.at(p.word, p.rule.pos1 - 1) == p.rule.thing
      p2? = Enum.at(p.word, p.rule.pos2 - 1) == p.rule.thing
      (p1? or p2?) and not (p1? and p2?)
    end)
  end
end

A.solve |> IO.inspect
