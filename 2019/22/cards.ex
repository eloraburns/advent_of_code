defmodule Cards do
  def load!(filename \\ "input.txt") do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn
      "deal into new stack" -> &deal_new/1
      "deal with increment " <> incr ->
        sincr = String.to_integer(incr)
        &deal_incr(&1, sincr)
      "cut " <> c ->
        sc = String.to_integer(c)
        &cut(&1, sc)
    end)
  end

  def deal_new(cards), do: Enum.reverse(cards)

  def cut(cards, at) when at > 0, do: Enum.drop(cards, at) ++ Enum.take(cards, at)
  def cut(cards, at), do: cut(cards, length(cards) + at)

  def deal_incr(cards, incr) do
    deck_length = length(cards)
    cards
    |> Enum.with_index
    |> Enum.reduce(:array.new(deck_length, []), fn {card, index}, deck ->
      :array.set(rem(index * incr, deck_length), card, deck)
    end)
    |> :array.to_list
  end

  def solve_1a(filename \\ "input.txt", num_cards \\ 10007) do
    load!(filename)
    |> Enum.reduce(Enum.to_list(0..(num_cards-1)), fn f, deck ->
      f.(deck)
    end)
    |> Enum.find_index(&(&1 == 2019))
  end

end
