defmodule Codegen do
  def gen(input, :a) do
    input
    |> String.split("\n")
    |> Enum.map(&gen_rule(&1, :a))
  end

  def gen(input, :b) do
    input
    |> String.split("\n")
    |> Enum.map(&gen_rule(&1, :b))
  end

  def gen_rule(line, :a) do
    [name, content] = String.split(line, ": ")
    case content do
      << ?", letter, ?" >> -> 
        """
        def rule_#{name}(false), do: false
        def rule_#{name}(<< #{letter}, rest::binary >>), do: rest
        def rule_#{name}(_), do: false
        """
      alternations ->
        options = alternations
        |> String.split(" | ")
        |> Enum.map(fn seq ->
          pipeline = seq
          |> String.split
          |> Enum.map(fn n -> "rule_#{n}" end)
          |> Enum.join(" |> ")
          "(b |> #{pipeline})"
        end)
        |> Enum.join(" || ")
        
        """
        def rule_#{name}(false), do: false
        def rule_#{name}(b) when is_binary(b) do
          #{options}
        end
        def rule_#{name}(_), do: false
        """
    end
  end

  def gen_rule(<< "8: ", _::binary >>, :b) do
    gen_rule("8: 42 | 42 8", :a)
  end
  def gen_rule(<< "11: ", _::binary >>, :b) do
    gen_rule("11: 42 31 | 42 11 31", :a)
  end
  def gen_rule(whatever, :b), do: gen_rule(whatever, :a)

  def gen_test_19b do
    File.write!("ruleset_test_19b.exs",
      "defmodule RulesetTest19b do\ndef run(b), do: rule_0(b) == \"\"\n\n#{
        "test.txt"
        |> File.read!
        |> String.split("\n\n")
        |> hd
        |> gen(:b)
        |> Enum.join("\n\n")
      }\nend"
    )
  end

  def gen_19a do
    File.write!("ruleset_19a.exs",
      "defmodule Ruleset19a do\ndef run(b), do: rule_0(b) == \"\"\n\n#{
        "input.txt"
        |> File.read!
        |> String.split("\n\n")
        |> hd
        |> gen(:a)
        |> Enum.join("\n\n")
      }\nend"
    )
  end

  def gen_19b do
    File.write!("ruleset_19b.exs",
      "defmodule Ruleset19b do\ndef run(b), do: rule_0(b) == \"\"\n\n#{
        "input.txt"
        |> File.read!
        |> String.split("\n\n")
        |> hd
        |> gen(:b)
        |> Enum.join("\n\n")
      }\nend"
    )
  end
end
