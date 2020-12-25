defmodule Cups do
  @start "123487596"

  def prev(?9), do: ?8
  def prev(?8), do: ?7
  def prev(?7), do: ?6
  def prev(?6), do: ?5
  def prev(?5), do: ?4
  def prev(?4), do: ?3
  def prev(?3), do: ?2
  def prev(?2), do: ?1
  def prev(?1), do: ?9

  def move(<< n, m1, m2, m3, a, b, c, d, e >> = h) do
    IO.inspect h
    cond do
      prev(n) == a -> << a, m1, m2, m3, b, c, d, e, n >>
      prev(n) == b -> << a, b, m1, m2, m3, c, d, e, n >>
      prev(n) == c -> << a, b, c, m1, m2, m3, d, e, n >>
      prev(n) == d -> << a, b, c, d, m1, m2, m3, e, n >>
      prev(n) == e -> << a, b, c, d, e, m1, m2, m3, n >>
      prev(prev(n)) == a -> << a, m1, m2, m3, b, c, d, e, n >>
      prev(prev(n)) == b -> << a, b, m1, m2, m3, c, d, e, n >>
      prev(prev(n)) == c -> << a, b, c, m1, m2, m3, d, e, n >>
      prev(prev(n)) == d -> << a, b, c, d, m1, m2, m3, e, n >>
      prev(prev(n)) == e -> << a, b, c, d, e, m1, m2, m3, n >>
      prev(prev(prev(n))) == a -> << a, m1, m2, m3, b, c, d, e, n >>
      prev(prev(prev(n))) == b -> << a, b, m1, m2, m3, c, d, e, n >>
      prev(prev(prev(n))) == c -> << a, b, c, m1, m2, m3, d, e, n >>
      prev(prev(prev(n))) == d -> << a, b, c, d, m1, m2, m3, e, n >>
      prev(prev(prev(n))) == e -> << a, b, c, d, e, m1, m2, m3, n >>
      prev(prev(prev(prev(n)))) == e -> << a, b, c, d, e, m1, m2, m3, n >>
      prev(prev(prev(prev(n)))) == a -> << a, m1, m2, m3, b, c, d, e, n >>
      prev(prev(prev(prev(n)))) == b -> << a, b, m1, m2, m3, c, d, e, n >>
      prev(prev(prev(prev(n)))) == c -> << a, b, c, m1, m2, m3, d, e, n >>
      prev(prev(prev(prev(n)))) == d -> << a, b, c, d, m1, m2, m3, e, n >>
      prev(prev(prev(prev(n)))) == e -> << a, b, c, d, e, m1, m2, m3, n >>
    end
  end

  def score(<<                       ?1, rest::binary >>), do: rest
  def score(<< head::binary-size(1), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(2), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(3), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(4), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(5), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(6), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(7), ?1, rest::binary >>), do: << rest::binary, head::binary >>
  def score(<< head::binary-size(8), ?1               >>), do: head

  def play(cups, rounds) do
    cups
    |> Stream.iterate(&move/1)
    |> Stream.drop(rounds)
    |> Enum.take(1)
    |> hd
    |> score
  end

  
  def test23a do
    IO.puts "Expect 92658374"
    play("389125467", 10)
  end

  def solve23a do
    play(@start, 100)
  end

end
