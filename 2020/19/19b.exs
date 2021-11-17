defmodule B do
  require Ruleset19a
  require Ruleset19b

  def compare_with_19a do
    {rules_regex, inputs} = "input.txt"
    |> File.read!
    |> A.parse

    inputs
    |> Enum.flat_map(fn input ->
      regex_disposition = Regex.match?(rules_regex, input)
      codegen_disposition = Ruleset19b.run(input)
      if regex_disposition != codegen_disposition do
        ["Disagreement about: #{input}\nregex:#{regex_disposition} codegen:#{codegen_disposition}"]
      else
        IO.write "Y"
        []
      end
    end)
  end

  def solve19a do
    "input.txt"
    |> File.read!
    |> String.split("\n\n")
    |> tl |> hd
    |> String.split("\n")
    |> Enum.map(&Ruleset19a.run/1)
    |> Enum.count(&(&1))
  end

  def solve19b do
    "input.txt"
    |> File.read!
    |> String.split("\n\n")
    |> tl |> hd
    |> String.split("\n")
    |> Enum.map(&Ruleset19b.run/1)
    |> Enum.count(&(&1))
    # 271 is too low
  end
end

defmodule Btest do
  def rule_0(false), do: false
  def rule_0(b) do
    b |> rule_4 |> rule_5 |> rule_1
  end

  def rule_1(false), do: false
  def rule_1(b) do
    (b |> rule_2 |> rule_3)
    ||
    (b |> rule_3 |> rule_2)
  end

  def rule_2(false), do: false
  def rule_2(b) do
    (b |> rule_4 |> rule_4)
    ||
    (b |> rule_5 |> rule_5)
  end

  def rule_3(false), do: false
  def rule_3(b) do
    (b |> rule_4 |> rule_5)
    ||
    (b |> rule_5 |> rule_4)
  end

  def rule_4(false), do: false
  def rule_4(<< ?a, rest::binary >>) do
    rest
  end
  def rule_4(_), do: false

  def rule_5(false), do: false
  def rule_5(<< ?b, rest::binary >>) do
    rest
  end
  def rule_5(_), do: false

  def run(b) do
    rule_0(b) == ""
  end

  def test do
    [
      {"ababbb", true},
      {"bababa", false},
      {"abbbab", true},
      {"aaabbb", false},
      {"aaaabbb", false},
      {"abaaab", true},
      {"abaaba", true},
      {"abbbab", true},
      {"abbbba", true},
      {"abbbbaa", true},
    ]
    |> Enum.map(fn {input, expected} ->
      case run(input) do
        ^expected -> {:ok, input}
        actual -> {:bad, input, expected, actual}
      end
    end)
  end

end
