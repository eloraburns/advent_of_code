defmodule RulesetTest19b do
def run(b), do: rule_0(b) == ""

def rule_0(false), do: false
def rule_0(b) when is_binary(b) do
  (b |> rule_4 |> rule_1 |> rule_5)
end
def rule_0(_), do: false


def rule_1(false), do: false
def rule_1(b) when is_binary(b) do
  (b |> rule_2 |> rule_3) || (b |> rule_3 |> rule_2)
end
def rule_1(_), do: false


def rule_2(false), do: false
def rule_2(b) when is_binary(b) do
  (b |> rule_4 |> rule_4) || (b |> rule_5 |> rule_5)
end
def rule_2(_), do: false


def rule_3(false), do: false
def rule_3(b) when is_binary(b) do
  (b |> rule_4 |> rule_5) || (b |> rule_5 |> rule_4)
end
def rule_3(_), do: false


def rule_4(false), do: false
def rule_4(<< 97, rest::binary >>), do: rest
def rule_4(_), do: false


def rule_5(false), do: false
def rule_5(<< 98, rest::binary >>), do: rest
def rule_5(_), do: false

end