defmodule Nine do
  defstruct [
    marbles: [0],
    current_marble: 0,
    num_marbles: 1,
    player_scores: %{},
    current_player: 0,
    num_players: 1,
  ]

  def max_score(%Nine{player_scores: player_scores}) do
    player_scores |> Map.values |> Enum.max
  end

  def place(%Nine{} = s, m) when rem(m, 23) == 0 do
    current_marble = case rem(s.current_marble - 7, s.num_marbles) do
      r when r >= 0 -> r
      r -> r + s.num_marbles
    end
    {popped, marbles} = List.pop_at(s.marbles, current_marble)
    dscore = m + popped
    %Nine{
      s |
      marbles: marbles,
      current_marble: current_marble,
      num_marbles: s.num_marbles - 1,
      player_scores: Map.update(s.player_scores, s.current_player, dscore, &(&1 + dscore)),
      current_player: rem(s.current_player + 1, s.num_players),
    }
  end

  def place(%Nine{} = s, m) do
    current_marble = rem(s.current_marble + 1, s.num_marbles) + 1
    marbles = List.insert_at(s.marbles, current_marble, m)
    %Nine{
      s |
      marbles: marbles,
      current_marble: current_marble,
      num_marbles: s.num_marbles + 1,
      current_player: rem(s.current_player + 1, s.num_players),
    }
  end

  def solve(players \\ 466, last_marble \\ 71436) do
    Enum.reduce(1..last_marble, %Nine{num_players: players}, fn m, acc -> Nine.place(acc, m) end)
    |> Nine.max_score
  end
    
end

# 382055
