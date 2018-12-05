defmodule P do
  def react(s) do
    s2 = react(s |> String.to_charlist, []) |> String.Chars.to_string
    if s == s2 do
      s
    else
      react(s2)
    end
  end

  defp react([], acc), do: Enum.reverse(acc)
  for {lower, upper} <- Enum.zip(?a..?z, ?A..?Z) do
    defp react([unquote(lower), unquote(upper) | rest], acc), do: react(rest, acc)
    defp react([unquote(upper), unquote(lower) | rest], acc), do: react(rest, acc)
  end
  defp react([h | rest], acc), do: react(rest, [h | acc])
end

File.read!("input.txt")
|> String.trim
|> (fn s ->
  Enum.zip(?a..?z, ?A..?Z)
  |> Enum.map(fn {lower, upper} -> s |> String.replace(<<lower>>, "") |> String.replace(<<upper>>, "") end)
end).()
|> Task.async_stream(&P.react/1)
|> Enum.map(fn {:ok, s} -> byte_size(s) end)
|> Enum.min
|> IO.puts

# 4572
# takes as little as 3s!
