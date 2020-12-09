defmodule A do
  defstruct [
    queue: :queue.new,
    set: MapSet.new
  ]

  def preload(list_of_n, state) do
    list_of_n
    |> Enum.reduce(state, fn n, s ->
      %A{
        queue: :queue.in(n, s.queue),
        set: s.set |> MapSet.put(n)
      }
    end)
  end

  def check_and_push(n, state) do
    Enum.any?(state.set, fn seen_n -> MapSet.member?(state.set, n - seen_n) and n != seen_n end)
    |> case do
      true ->
        {{:value, old_n}, short_q} = :queue.out(state.queue)
        {:cont, %A{
          queue: :queue.in(n, short_q),
          set: state.set |> MapSet.delete(old_n) |> MapSet.put(n)
        }}
      false ->
        {:halt, {:bad_number, n}}
    end
  end

  def solve(filename, lookback) do
    f = File.stream!(filename) |> Stream.map(&String.trim/1) |> Stream.map(&String.to_integer/1)
    s = f |> Stream.take(lookback) |> preload(%A{})
    f |> Stream.drop(lookback) |> Enum.reduce_while(s, &check_and_push/2)
  end

  def test9a do
    solve("test.txt", 5)
  end

  def solve9a do
    solve("input.txt", 25)
  end

end
