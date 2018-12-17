defmodule Fourteen do
  @initial_state {:array.from_list([3, 7]), 0, 1}

  def step({scores, e1, e2}) do
    e1s = :array.get(e1, scores)
    e2s = :array.get(e2, scores)

    new_scores = (e1s + e2s)
    |> Integer.to_string
    |> String.to_charlist
    |> Enum.reduce(scores, fn score, scores ->
      :array.set(:array.size(scores), score - ?0, scores)
    end)

    ne1 = rem((e1 + e1s + 1), :array.size(new_scores))
    ne2 = rem((e2 + e2s + 1), :array.size(new_scores))
    {new_scores, ne1, ne2}
  end

  def solve(drop_n \\ 360781) do
    need_at_least = drop_n + 10
    Stream.cycle([0])
    |> Enum.reduce_while(@initial_state, fn _, {a, _, _} = s ->
      if :array.size(a) >= need_at_least do
        {:halt, a |> :array.to_list |> Enum.drop(drop_n) |> Enum.take(10) |> Enum.map(&Integer.to_string/1) |> Enum.join("")}
      else
        {:cont, step(s)}
      end
    end)
  end

end
