defmodule A do
  def lex(l) do
    l |> String.trim |> String.replace(" ", "") |> String.to_charlist |> Enum.map(fn
      d when d in ?0..?9 -> d - ?0
      ?( -> :open
      ?) -> :close
      ?+ -> :+
      ?* -> :*
    end)
  end

  def sublistify(tokens, acc \\ [[]])
  def sublistify([], acc), do: hd(acc) |> Enum.reverse
  def sublistify([:open | rest], acc) do
    sublistify(rest, [[] | acc])
  end
  def sublistify([:close | rest], [current | [h | acc]]) do
    sublistify(rest, [[Enum.reverse(current) | h] | acc])
  end
  def sublistify([t | rest], [current | acc]) do
    sublistify(rest, [[t | current] | acc])
  end

  def eval(num) when is_number(num), do: num
  def eval([l]), do: eval(l)
  def eval([e1, op, e2]) do
    #IO.inspect [e1, op, e2]
    case op do
      :+ -> eval(e1) + eval(e2)
      :* -> eval(e1) * eval(e2)
    end
  end
  def eval([e1, op, e2 | more]) do
    #IO.inspect {[e1, op, e2], more}
    case op do
      :+ -> eval([eval(e1) + eval(e2) | more])
      :* -> eval([eval(e1) * eval(e2) | more])
    end
  end

  def solve18b do
    File.stream!("input.txt")
    |> Enum.map(&lex/1)
    |> Enum.map(&(&1 |> sublistify |> eval))
    |> Enum.sum
    # 13025936114884 is too low
    # 23507031841020!
  end

  def test do
    [
      {"1", 1},
      {"1 + 2", 3},
      {"1 + 2 + 3", 6},
      {"1 * 2 + 3", 5},
      {"1 + 2 * 3", 9},
      {"1 + (2 * 3)", 7},
      {"1 + (2 * 3) + (4 * (5 + 6))", 51},
      {"2 * 3 + (4 * 5)", 46},
      {"5 + (8 * 3 + 9 + 3 * 4 * 3)", 1445},
      {"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 669060},
      {"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 23340}
    ]
    |> Enum.map(fn {input, expected} ->
      case input |> lex |> sublistify |> eval do
        ^expected -> {:ok, input}
        actual -> {:wrong, input, expected, actual}
      end
    end)

  end


  # num := 0..9
  # op := + | *
  # expr := "(" expr ")" | expr op expr | num


  # {:parens, subexp}
  # {:op, op, left, right}
  # literal_integer

  # 1 + 2           {1, :+, 2}
  # 1 + 2 + 3       {1, :+, {2, :+, 3}}
  # ( 1 + 2 )       {1, :+, 2}
  # ( 1 + 2 ) + 3   {{1, :+, 2}, :+ 3}
  # 1 + ( 2 + 3 )   {1, :+, {2, :+, 3}}

  # 1 + 2           [1][]  [1][+]  [1, 2][+]
  # 1 + 2 + 3       {1, :+, {2, :+, 3}}
  # ( 1 + 2 )       {1, :+, 2}
  # ( 1 + 2 ) + 3   {{1, :+, 2}, :+ 3}
  # 1 + ( 2 + 3 )   {1, :+, {2, :+, 3}}

  # def to_rpn(tokens, stack \\ [], op_stack \\ [])
  # def to_rpn([n | rest], stack, op_stack) when n in ?0..?9 do
  #   to_rpn(rest, [n | stack], op_stack)
  # end
  # def to_rpn([op | rest], stack, op_stack) when op in [?+, ?*] do
  #   to_rpn(rest, stack, [op | op_stack])
  # end
  # def to_rpn([?( | rest], stack, op_stack) do
  # end
  #   


  # def parse_e([n | rest]) when n in ?0..?9 do
  # end

  # def parse(tokens, pushdown \\ [[]])
  # def parse([], [pushdown]), do: eval(pushdown)
  # def parse([?( | rest], pushdown) do
  #   parse(rest, [[] | pushdown])
  # end
  # def parse([?) | rest], [pushhead | pushdown]) do
  #   parse(rest, [eval(pushhead) | pushdown])
  # end
  # def parse([n | rest], [pushhead | pushdown]) when ?0 <= n and n <= ?9 do
  #   parse(rest, [[n - ?0 | pushhead] | pushdown])
  # end
  # def parse([op | rest], [pushhead | pushdown]) do
  #   parse(rest, [[op | pushhead] | pushdown])
  # end

  #def eval([n]), do: n
  #def eval([n, ?+ | rest]), do: n + eval(rest)
  #def eval([n, ?* | rest]), do: n * eval(rest)


end
