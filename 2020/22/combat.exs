defmodule Combat do
  defmodule State do
    defstruct player1: :queue.new, player2: :queue.new
  end

  def load(filename \\ "input.txt") do
    File.read!(filename)
  end

  def parse(input) do
    [player1, player2] = input
    |> String.split("\n\n")
    |> Enum.map(fn hand ->
      hand
      |> String.trim
      |> String.split("\n")
      |> tl
      |> Enum.map(&String.to_integer/1)
      |> :queue.from_list
    end)
    %State{player1: player1, player2: player2}
  end

  def score(hand) do
    hand
    |> :queue.to_list
    |> Enum.reverse
    |> Enum.with_index(1)
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum
  end

  def play(%State{player1: player1, player2: player2}) do
    case {:queue.out(player1), :queue.out(player2)} do
      {{{:value, p1c}, p1h}, {{:value, p2c}, p2h}} when p1c > p2c ->
        %State{player1: :queue.in(p2c, :queue.in(p1c, p1h)), player2: p2h}
      {{{:value, p1c}, p1h}, {{:value, p2c}, p2h}} when p1c < p2c ->
        %State{player1: p1h, player2: :queue.in(p1c, :queue.in(p2c, p2h))}
      {{{:value, p1c}, _p1h}, {{:value, p2c}, _p2h}} ->
        {:error, :cards_equal, p1c, p2c}
      {{:empty, _}, {:empty, _}} ->
        {:error, :two_empty_hands}
      {{:empty, _}, _} ->
        {:won, :player2, score(player2)}
      {_, {:empty, _}} ->
        {:won, :player1, score(player1)}
    end
  end

  def solve(filename) do
    filename
    |> load
    |> parse
    |> Stream.iterate(&play/1)
    |> Enum.drop_while(fn
      {:ok, _} -> true
      _ -> false
    end)
    |> Enum.take(1)
    |> hd
    |> elem(2)
  end

  def test22a do
    solve("test.txt")
  end

  def solve22a do
    solve("input.txt")
  end

end
