defmodule Fourteen do
  @initial_state {:array.from_list([3, 7]), 0, 1}

  def step(_, {scorelist, e1, e2}) do
    e1s = :array.get(e1, scorelist)
    e2s = :array.get(e2, scorelist)

    new_scores = (e1s + e2s)
    |> Integer.to_string
    |> String.to_charlist
    |> Enum.map(&(&1 - ?0))

    new_scorelist = Enum.reduce(new_scores, scorelist, fn s, sl ->
      :array.set(:array.size(sl), s, sl)
    end)

    ne1 = rem((e1 + e1s + 1), :array.size(new_scorelist))
    ne2 = rem((e2 + e2s + 1), :array.size(new_scorelist))
    {new_scores, {new_scorelist, ne1, ne2}}
  end

  def stream() do
    Stream.concat(
      [3, 7],
      Stream.transform(Stream.cycle([0]), @initial_state, &step/2)
    )
  end

  def chunk5(s) do
    init = Enum.take(s, 4) |> List.to_tuple
    Stream.transform(
      Stream.drop(s, 4),
      init,
      fn e, {a, b, c, d} ->
        {[{a, b, c, d, e}], {b, c, d, e}}
      end
    )
  end

  def chunk6(s) do
    init = Enum.take(s, 5) |> List.to_tuple
    Stream.transform(
      Stream.drop(s, 5),
      init,
      fn f, {a, b, c, d, e} ->
        {[{a, b, c, d, e, f}], {b, c, d, e, f}}
      end
    )
  end

  def solve_sample() do
    Fourteen.stream |> chunk5() |> Stream.with_index |> Stream.drop_while(fn
      {{5, 9, 4, 1, 4}, _} -> false
      _ -> true
    end) |> Enum.take(1) |> hd |> elem(1)
  end

  def solve_terrible() do
    Fourteen.stream |> chunk6() |> Stream.with_index |> Stream.drop_while(fn
      {{3, 6, 0, 7, 8, 1}, _} -> false
      _ -> true
    end) |> Enum.take(1) |> hd |> elem(1)
  end

  def solve() do
    Fourteen.stream |> Stream.chunk_every(6, 1) |> Stream.with_index |> Stream.drop_while(fn
      {[3, 6, 0, 7, 8, 1], _} -> false
      _ -> true
    end) |> Enum.take(1) |> hd |> elem(1)
  end
end
