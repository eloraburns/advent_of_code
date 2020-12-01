defmodule A do
  defp blurp(l, acc \\ [])
  defp blurp([], acc), do: acc
  defp blurp([_], acc), do: acc
  defp blurp([h | t], acc), do: blurp(t, [{h, t} | acc])

  def alltriples(l) do
    for {a, r1} <- blurp(l),
      {b, r2} <- blurp(r1),
      c <- r2 do
        {a, b, c}
    end
  end
end

File.stream!("input.txt")
|> Enum.map(&Integer.parse/1)
|> Enum.map(&elem(&1, 0))
|> A.alltriples
|> Enum.filter(fn {a, b, c} -> (a + b + c) == 2020 end)
|> hd
|> (fn {a, b, c} -> a * b * c end).()
|> IO.puts
