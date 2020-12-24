defmodule RecursiveCombat do
  defmodule Hand do
    defstruct cards: :queue.new, num_cards: 0

    def from_list(l) do
      %Hand{cards: :queue.from_list(l), num_cards: length(l)}
    end

    def grab_top(hand) do
      case :queue.out(hand.cards) do
        {:empty, empty} -> {:empty, %Hand{cards: empty, num_cards: 0}}
        {{:value, card}, rest} -> {{:value, card}, %Hand{cards: rest, num_cards: hand.num_cards - 1}}
      end
    end

    def add_bottom(hand, card1, card2) do
      %Hand{cards: :queue.in(card2, :queue.in(card1, hand.cards)), num_cards: hand.num_cards + 2}
    end

    def serialize(%Hand{cards: cards, num_cards: num_cards}) do
      {num_cards, :queue.to_list(cards)}
    end

    def score(%Hand{cards: cards}) do
      cards
      |> :queue.to_list
      |> Enum.reverse
      |> Enum.with_index(1)
      |> Enum.map(fn {x, y} -> x * y end)
      |> Enum.sum
    end

    def only(hand, num_cards) do
      %Hand{
        cards: hand.cards |> :queue.to_list |> Enum.take(num_cards) |> :queue.from_list,
        num_cards: num_cards
      }
    end
  end

  defimpl String.Chars, for: Hand do
    def to_string(hand) do
      "Deck: #{hand.cards |> :queue.to_list |> Enum.map(&Integer.to_string/1) |> Enum.join(" ")}"
    end
  end

  defmodule State do
    defstruct player1: :queue.new, player2: :queue.new, seen_hands: []
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
      |> Hand.from_list
    end)
    %State{player1: player1, player2: player2}
  end

  def play({:won, _, _} = w) do
    IO.inspect w
    raise "wstsf"
  end
  def play(%State{player1: player1, player2: player2, seen_hands: seen_hands}) do
    #IO.puts player1
    #IO.puts player2
    #IO.inspect seen_hands
    this_pair_of_hands = {Hand.serialize(player1), Hand.serialize(player2)}
    if this_pair_of_hands in seen_hands do
      {:won, :player1, Hand.score(player1)}
    else
      case {Hand.grab_top(player1), Hand.grab_top(player2)} do
        {{{:value, p1c}, p1h}, {{:value, p2c}, p2h}} when p1c <= p1h.num_cards and p2c <= p2h.num_cards ->
          #IO.puts "RECURSE"
          case play_to_end(%State{player1: Hand.only(p1h, p1c), player2: Hand.only(p2h, p2c)}) do
            {:won, :player1, _} ->
              %State{player1: Hand.add_bottom(p1h, p1c, p2c), player2: p2h, seen_hands: [ this_pair_of_hands | seen_hands]}
            {:won, :player2, _} -> 
              %State{player1: p1h, player2: Hand.add_bottom(p2h, p2c, p1c), seen_hands: [ this_pair_of_hands | seen_hands]}
          end
        {{{:value, p1c}, p1h}, {{:value, p2c}, p2h}} when p1c > p2c ->
          %State{player1: Hand.add_bottom(p1h, p1c, p2c), player2: p2h, seen_hands: [ this_pair_of_hands | seen_hands]}
        {{{:value, p1c}, p1h}, {{:value, p2c}, p2h}} when p1c < p2c ->
          %State{player1: p1h, player2: Hand.add_bottom(p2h, p2c, p1c), seen_hands: [ this_pair_of_hands | seen_hands]}
        {{{:value, p1c}, _p1h}, {{:value, p2c}, _p2h}} ->
          {:error, :cards_equal, p1c, p2c}
        {{:empty, _}, {:empty, _}} ->
          {:error, :two_empty_hands}
        {{:empty, _}, _} ->
          {:won, :player2, Hand.score(player2)}
        {_, {:empty, _}} ->
          {:won, :player1, Hand.score(player1)}
      end
    end
  end

  def play_to_end({:won, _, _} = won), do: won
  def play_to_end(%State{} = state) do
    state |> play |> play_to_end
  end

  def solve(filename) do
    filename
    |> load
    |> parse
    |> play_to_end
    |> elem(2)
  end

  def test22b do
    solve("test.txt")
  end

  def solve22b do
    solve("input.txt")
  end

end
