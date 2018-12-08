defmodule Seven do

  defmodule Worker do
    defstruct [
      step: nil,
      seconds_left: 0,
    ]

    def new(step, step_time_offset) do
      %Worker{step: step, seconds_left: step + step_time_offset}
    end

    def tick(%Worker{} = w) do
      Map.put(w, :seconds_left, w.seconds_left - 1)
    end
  end

  defstruct [
    num_workers: 0,
    step_time_offset: 0,
    workers: [],
    graph: %{},
  ]

  def load_graph(input_filename) do
    File.stream!(input_filename)
    |> Enum.map(fn << "Step ", a, " must be finished before step ", b, " can begin.\n" >> -> {a, b} end)
    |> Enum.reduce(%{}, fn {a, b}, acc ->
      acc
      |> Map.update(a, [b], &([b|&1]))
      |> Map.put_new(b, [])
    end)
  end

  def find_empty_incoming(g) do
    all_targets = g
    |> Map.values
    |> Enum.concat
    |> MapSet.new

    empty_incoming = g
    |> Map.keys
    |> MapSet.new
    |> MapSet.difference(all_targets)
    |> Enum.sort
  end

  def except(l1, l2) do
    steps = l2 |> Enum.map(&(&1.step)) |> MapSet.new
    Enum.reject(l1, &(&1 in steps))
  end

  def tick(%Seven{} = state) do
    {done_workers, working_workers} = state.workers
    |> Enum.map(&Worker.tick/1)
    |> Enum.split_with(&(&1.seconds_left == 0))

    g2 = state.graph
    |> Map.drop(Enum.map(done_workers, &(&1.step)))

    worker_headroom = state.num_workers - length(working_workers)
    new_workers = case worker_headroom do
      0 -> []
      n -> g2 |> find_empty_incoming() |> except(working_workers) |> Enum.take(n) |> Enum.map(&Worker.new(&1, state.step_time_offset))
    end ++ working_workers

    %Seven{ state | workers: new_workers, graph: g2 }
  end

  def solve(input_filename \\ "input.txt", num_workers \\ 5, step_time_offset \\ (60 + 1 - ?A)) do
    g = load_graph(input_filename)

    Enum.reduce_while(
      -1..100000,
      %Seven{num_workers: num_workers, step_time_offset: step_time_offset, graph: g},
      fn
        t, %Seven{workers: workers, graph: g} when length(workers) == 0 and map_size(g) == 0 ->
          {:halt, t}
        _, acc ->
          {:cont, tick(acc)}
      end
     )
  end
end

# 1696 is too high
# 906 actually. Can't be re-enqueuing existing things!
