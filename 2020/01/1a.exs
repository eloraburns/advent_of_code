defmodule A do
  def allpairs([]), do: []
  def allpairs([_]), do: []

  def allpairs(l, acc \\ [])
  def allpairs([], acc), do: acc
  def allpairs([h | t], acc) do
    allpairs(t, dopairs(h, t, acc))
  end

  defp dopairs(_, [], acc), do: acc
  defp dopairs(n, [h | t], acc) do
    dopairs(n, t, [{n, h} | acc])
  end
end

File.stream!("input.txt")
|> Enum.map(&Integer.parse/1)
|> Enum.map(&elem(&1, 0))
|> A.allpairs
|> Enum.filter(fn {a, b} -> (a + b) == 2020 end)
|> hd
|> (fn {a, b} -> a * b end).()
|> IO.puts
