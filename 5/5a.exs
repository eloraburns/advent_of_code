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
|> P.react
|> byte_size
|> IO.puts

# 10132
