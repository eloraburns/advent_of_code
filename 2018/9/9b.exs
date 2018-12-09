defmodule Nine do

  defstruct [
    lm: [0],
    rm: [],
    player_scores: %{},
    current_player: 0,
    num_players: 1,
  ]

  def max_score(%Nine{player_scores: player_scores}) do
    player_scores |> Map.values |> Enum.max
  end

  def unshift(l, r, 0), do: {l, r}
  def unshift([], r, n) do 
    [hl | l] = Enum.reverse(r)
    unshift(l, [hl], n - 1)
  end
  def unshift([hl | l], r, n) do
    unshift(l, [hl | r], n - 1)
  end

  def place(%Nine{} = s, m) when rem(m, 23) == 0 do
    {l, r, popped} = case unshift(s.lm, s.rm, 8) do
      {l, [x, y | r]} -> {[y | l], r, x}
      {l, [x]} -> {[], Enum.reverse(l), x}
    end
    dscore = m + popped
    %Nine{
      s |
      lm: l,
      rm: r,
      player_scores: Map.update(s.player_scores, s.current_player, dscore, &(&1 + dscore)),
      current_player: rem(s.current_player + 1, s.num_players),
    }
  end

  def place(%Nine{lm: lm, rm: [nm | rm]} = s, m) do
    %Nine{
      s |
      lm: [m, nm | lm],
      rm: rm,
      current_player: rem(s.current_player + 1, s.num_players),
    }
  end

  def place(%Nine{lm: lm, rm: []} = s, m) do
    [nm | rm] = Enum.reverse(lm)
    %Nine{
      s |
      lm: [m, nm],
      rm: rm,
      current_player: rem(s.current_player + 1, s.num_players),
    }
  end

  def solve(players \\ 466, last_marble \\ 7143600) do
    Enum.reduce(1..last_marble, %Nine{num_players: players}, fn m, acc -> Nine.place(acc, m) end)
    |> Nine.max_score
  end
    
end

# 3133277384
