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

  def find_sum_stream_bookend_sum(_target_n, []), do: {:error, "couldn't find any sum streams"}
  def find_sum_stream_bookend_sum(target_n, l) do
    #IO.puts("  *")
    Enum.reduce_while(l, {0, Enum.max(l), Enum.min(l)}, fn n, {acc, min, max} ->
      new_acc = n + acc
      new_min = Enum.min([n, min])
      new_max = Enum.max([n, max])
      #IO.puts("    * +#{n} = #{new_acc}")
      cond do
        new_acc < target_n -> {:cont, {new_acc, new_min, new_max}}
        new_acc == target_n -> {:halt, new_min + new_max}
        new_acc > target_n -> {:halt, :nope}
      end
    end)
    |> case do
      :nope -> find_sum_stream_bookend_sum(target_n, tl(l))
      answer -> answer
    end
  end

  def solve(filename, lookback) do
    f = File.stream!(filename) |> Stream.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
    s = f |> Enum.take(lookback) |> preload(%A{})
    {:bad_number, n} = f |> Enum.drop(lookback) |> Enum.reduce_while(s, &check_and_push/2)
    #IO.puts("* #{n}")
    find_sum_stream_bookend_sum(n, f)
  end

  def test9b do
    solve("test.txt", 5)
  end

  def solve9b do
    solve("input.txt", 25)
  end

end
