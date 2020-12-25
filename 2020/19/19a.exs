defmodule A do
  def parse(input) do
    [rules_s, messages_s] = String.split(input, "\n\n")

    rules_regex = rules_s
    |> String.split("\n")
    |> Enum.map(fn rule_s ->
      [rule_num, rule_content] = String.split(rule_s, ": ")
      rules = case rule_content do
        << ?", _::binary >> = c -> {:literal, String.trim(c, "\"")}
        c -> {:alternation, c |> String.split(" | ") |> Enum.map(&String.split/1)}
      end
      {rule_num, rules}
    end)
    |> Map.new
    |> to_regex_binary("0")
    |> (fn r -> "^#{r}$" end).()
    |> Regex.compile!

    {
      rules_regex,
      messages_s |> String.split("\n")
    }
  end

  def to_regex_binary(rule_map, rule) do
    case Map.get(rule_map, rule) do
      {:literal, l} -> l
      {:alternation, alts} ->
        "(#{
          Enum.map(alts, fn seq ->
            Enum.map(seq, &to_regex_binary(rule_map, &1))
            |> Enum.join("")
          end)
          |> Enum.join("|")
        })"
    end
  end

  def test19a do
    IO.puts "expect 2"
    {rules, messages} = File.read!("test.txt") |> parse
    Enum.count(messages, &Regex.match?(rules, &1))
  end

  def solve19a do
    {rules, messages} = File.read!("input.txt") |> parse
    Enum.count(messages, &Regex.match?(rules, &1))
  end

end
